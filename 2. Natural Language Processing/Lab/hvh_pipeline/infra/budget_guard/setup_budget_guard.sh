#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  infra/budget_guard/setup_budget_guard.sh \
    --target-project PROJECT_ID \
    --control-project PROJECT_ID \
    --billing-account BILLING_ACCOUNT_ID [options]

Required:
  --target-project     Dedicated project that runs HVH OCR workers.
  --control-project    Separate project that hosts Pub/Sub and the kill-switch function.
  --billing-account    Billing account ID, for example 000000-000000-000000.

Options:
  --budget USD         Monthly budget amount. Default: 100
  --region REGION      Cloud Functions region. Default: asia-southeast1
  --topic NAME         Pub/Sub topic name. Default: hvh-budget-kill-switch
  --function NAME      Cloud Function name. Default: hvh-budget-kill-switch
  --locations CSV      Filestore locations to scan. Default: asia-southeast1-a
  --delete-gcs         Also delete labeled GCS buckets and all contained objects.
  --no-disable-billing Delete resources but do not unlink billing.
  --yes                Do not prompt for confirmation.
  -h, --help           Show help.

This creates a monthly budget scoped to --target-project. At 100% actual spend,
Google publishes a Pub/Sub notification. The function deletes resources labeled
app=hvh-ocr and then disables billing for the target project unless disabled.
EOF
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FUNCTION_SOURCE="${SCRIPT_DIR}/function"
TARGET_PROJECT=""
CONTROL_PROJECT=""
BILLING_ACCOUNT=""
BUDGET_AMOUNT="100"
REGION="asia-southeast1"
TOPIC="hvh-budget-kill-switch"
FUNCTION_NAME="hvh-budget-kill-switch"
FILESTORE_LOCATIONS="asia-southeast1-a"
DELETE_GCS="false"
DISABLE_BILLING="true"
ASSUME_YES="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-project)
      TARGET_PROJECT="${2:?--target-project requires a value}"
      shift 2
      ;;
    --control-project)
      CONTROL_PROJECT="${2:?--control-project requires a value}"
      shift 2
      ;;
    --billing-account)
      BILLING_ACCOUNT="${2:?--billing-account requires a value}"
      shift 2
      ;;
    --budget)
      BUDGET_AMOUNT="${2:?--budget requires a value}"
      shift 2
      ;;
    --region)
      REGION="${2:?--region requires a value}"
      shift 2
      ;;
    --topic)
      TOPIC="${2:?--topic requires a value}"
      shift 2
      ;;
    --function)
      FUNCTION_NAME="${2:?--function requires a value}"
      shift 2
      ;;
    --locations)
      FILESTORE_LOCATIONS="${2:?--locations requires a value}"
      shift 2
      ;;
    --delete-gcs)
      DELETE_GCS="true"
      shift
      ;;
    --no-disable-billing)
      DISABLE_BILLING="false"
      shift
      ;;
    --yes)
      ASSUME_YES="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$TARGET_PROJECT" || -z "$CONTROL_PROJECT" || -z "$BILLING_ACCOUNT" ]]; then
  usage >&2
  exit 2
fi

if [[ "$TARGET_PROJECT" == "$CONTROL_PROJECT" ]]; then
  echo "Use a separate --control-project so the kill switch can still run after target billing is disabled." >&2
  exit 2
fi

if ! gcloud auth print-access-token >/dev/null 2>&1; then
  echo "gcloud auth is not usable. Run: gcloud auth login" >&2
  exit 1
fi

SA_NAME="hvh-budget-killer"
SA_EMAIL="${SA_NAME}@${CONTROL_PROJECT}.iam.gserviceaccount.com"
TOPIC_RESOURCE="projects/${CONTROL_PROJECT}/topics/${TOPIC}"

cat <<EOF
Budget guard setup
  target project:   ${TARGET_PROJECT}
  control project:  ${CONTROL_PROJECT}
  billing account:  ${BILLING_ACCOUNT}
  monthly budget:   ${BUDGET_AMOUNT} USD
  function region:  ${REGION}
  topic:            ${TOPIC_RESOURCE}
  delete GCS:       ${DELETE_GCS}
  disable billing:  ${DISABLE_BILLING}
EOF

if [[ "$ASSUME_YES" != "true" ]]; then
  read -r -p "Continue? Type 'yes': " answer
  if [[ "$answer" != "yes" ]]; then
    echo "Aborted."
    exit 1
  fi
fi

echo "Enabling required APIs..."
gcloud services enable \
  cloudbilling.googleapis.com \
  billingbudgets.googleapis.com \
  pubsub.googleapis.com \
  cloudfunctions.googleapis.com \
  run.googleapis.com \
  eventarc.googleapis.com \
  cloudbuild.googleapis.com \
  artifactregistry.googleapis.com \
  --project "$CONTROL_PROJECT"

gcloud services enable \
  compute.googleapis.com \
  file.googleapis.com \
  storage.googleapis.com \
  cloudbilling.googleapis.com \
  --project "$TARGET_PROJECT"

echo "Creating Pub/Sub topic if needed..."
gcloud pubsub topics create "$TOPIC" --project "$CONTROL_PROJECT" >/dev/null 2>&1 || true

echo "Creating runtime service account if needed..."
gcloud iam service-accounts create "$SA_NAME" \
  --display-name="HVH budget kill switch" \
  --project "$CONTROL_PROJECT" >/dev/null 2>&1 || true

echo "Granting runtime permissions..."
for role in roles/compute.admin roles/file.editor roles/storage.admin roles/billing.projectManager; do
  gcloud projects add-iam-policy-binding "$TARGET_PROJECT" \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="$role" \
    --quiet >/dev/null
done

gcloud billing accounts add-iam-policy-binding "$BILLING_ACCOUNT" \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/billing.user" \
  --quiet >/dev/null || true

echo "Deploying Cloud Run Function..."
gcloud functions deploy "$FUNCTION_NAME" \
  --gen2 \
  --runtime=python312 \
  --region="$REGION" \
  --project="$CONTROL_PROJECT" \
  --source="$FUNCTION_SOURCE" \
  --entry-point=handle_budget_alert \
  --trigger-topic="$TOPIC" \
  --service-account="$SA_EMAIL" \
  --memory=512Mi \
  --timeout=540s \
  --set-env-vars="TARGET_PROJECT=${TARGET_PROJECT},HARD_LIMIT_USD=${BUDGET_AMOUNT},TARGET_FILESTORE_LOCATIONS=${FILESTORE_LOCATIONS},DELETE_GCS_BUCKETS=${DELETE_GCS},DISABLE_BILLING=${DISABLE_BILLING}" \
  --quiet

echo "Creating monthly budget and Pub/Sub notification rule..."
gcloud billing budgets create \
  --billing-account="$BILLING_ACCOUNT" \
  --display-name="HVH OCR monthly guard ${TARGET_PROJECT}" \
  --budget-amount="${BUDGET_AMOUNT}USD" \
  --calendar-period=month \
  --filter-projects="projects/${TARGET_PROJECT}" \
  --threshold-rule=percent=0.50,basis=current-spend \
  --threshold-rule=percent=0.80,basis=current-spend \
  --threshold-rule=percent=0.90,basis=forecasted-spend \
  --threshold-rule=percent=1.00,basis=current-spend \
  --notifications-rule-pubsub-topic="$TOPIC_RESOURCE"

cat <<EOF
Done.

Important:
- Budget data can lag, so this is a strong guardrail, not an exact hard cap.
- The kill switch removes resources labeled app=hvh-ocr. The Terraform worker
  resources use that label.
- If the function logs a permission error while disabling billing, grant the
  runtime service account stronger billing permissions on the billing account.
EOF
