#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  infra/run_gce_workers.sh [options]

Options:
  --workers N        Override Terraform worker_count for this run.
  --shared-storage   Create and mount shared Filestore storage for images/cache/output.
  --smoke-test       Run one capped OCR smoke test, wrapped in a 10 minute timeout.
  --smoke-unit CODE  Unit for --smoke-test. Default: HVH_100.
  --smoke-pages N    Page cap for --smoke-test. Default: 1.
  --smoke-timeout T  Timeout for smoke OCR command. Default: 10m.
  --startup-smoke   Run the capped smoke test from a VM startup script; skips Ansible.
  --startup-timeout T
                    Timeout while waiting for startup-smoke status. Default: 20m.
  --artifact-dir D  Local directory for downloaded startup-smoke artifacts.
                    Default: infra/artifacts/smoke
  --tfvars PATH      Terraform tfvars file. Default: infra/terraform/terraform.tfvars
  --auto-approve     Pass -auto-approve to terraform apply/destroy.
  --skip-init        Skip terraform init.
  --skip-apply       Do not create or update infrastructure.
  --skip-ansible     Do not run the Ansible provision/OCR playbook.
  --destroy-after    Destroy Terraform resources after Ansible completes.
  -h, --help         Show this help.

Environment:
  KHN_USERNAME and KHN_PASSWORD are forwarded by Ansible if the OCR site
  requires login.

Typical smoke test:
  infra/run_gce_workers.sh --workers 1 --smoke-test --auto-approve
EOF
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="${SCRIPT_DIR}/terraform"
ANSIBLE_DIR="${SCRIPT_DIR}/ansible"
TFVARS="${TF_DIR}/terraform.tfvars"
WORKERS=""
SHARED_STORAGE=false
SMOKE_TEST=false
SMOKE_UNIT="HVH_100"
SMOKE_PAGES="1"
SMOKE_TIMEOUT="10m"
STARTUP_SMOKE=false
STARTUP_TIMEOUT="20m"
ARTIFACT_DIR="${SCRIPT_DIR}/artifacts/smoke"
AUTO_APPROVE=false
RUN_INIT=true
RUN_APPLY=true
RUN_ANSIBLE=true
DESTROY_AFTER=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --workers)
      WORKERS="${2:?--workers requires a value}"
      shift 2
      ;;
    --shared-storage)
      SHARED_STORAGE=true
      shift
      ;;
    --smoke-test)
      SMOKE_TEST=true
      shift
      ;;
    --smoke-unit)
      SMOKE_UNIT="${2:?--smoke-unit requires a value}"
      shift 2
      ;;
    --smoke-pages)
      SMOKE_PAGES="${2:?--smoke-pages requires a value}"
      shift 2
      ;;
    --smoke-timeout)
      SMOKE_TIMEOUT="${2:?--smoke-timeout requires a value}"
      shift 2
      ;;
    --startup-smoke)
      STARTUP_SMOKE=true
      shift
      ;;
    --startup-timeout)
      STARTUP_TIMEOUT="${2:?--startup-timeout requires a value}"
      shift 2
      ;;
    --artifact-dir)
      ARTIFACT_DIR="${2:?--artifact-dir requires a value}"
      shift 2
      ;;
    --tfvars)
      TFVARS="${2:?--tfvars requires a value}"
      shift 2
      ;;
    --auto-approve)
      AUTO_APPROVE=true
      shift
      ;;
    --skip-init)
      RUN_INIT=false
      shift
      ;;
    --skip-apply)
      RUN_APPLY=false
      shift
      ;;
    --skip-ansible)
      RUN_ANSIBLE=false
      shift
      ;;
    --destroy-after)
      DESTROY_AFTER=true
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

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

duration_to_seconds() {
  local value="${1:?duration is required}"
  case "$value" in
    *s) echo "${value%s}" ;;
    *m) echo $(( ${value%m} * 60 )) ;;
    *h) echo $(( ${value%h} * 3600 )) ;;
    *[!0-9]*)
      echo "Unsupported duration: $value. Use seconds, or suffix s, m, or h." >&2
      exit 2
      ;;
    *) echo "$value" ;;
  esac
}

if [[ "$STARTUP_SMOKE" == true ]]; then
  RUN_ANSIBLE=false
  if [[ -z "$WORKERS" ]]; then
    WORKERS=1
  elif [[ "$WORKERS" != "1" ]]; then
    echo "--startup-smoke supports exactly one worker; got --workers $WORKERS" >&2
    exit 2
  fi
fi

require_command terraform
if [[ "$RUN_ANSIBLE" == true ]]; then
  require_command ansible-playbook
fi
if [[ "$SMOKE_TEST" == true || "$STARTUP_SMOKE" == true ]]; then
  require_command timeout
fi
if [[ "$STARTUP_SMOKE" == true ]]; then
  require_command gcloud
fi

if [[ ! -f "$TFVARS" ]]; then
  echo "Missing Terraform variables file: $TFVARS" >&2
  echo "Create it from ${TF_DIR}/terraform.tfvars.example and fill in project_id and SSH key paths." >&2
  exit 1
fi

TF_ARGS=(-var-file="$TFVARS")
if [[ -n "$WORKERS" ]]; then
  TF_ARGS+=(-var="worker_count=${WORKERS}")
fi
if [[ "$SHARED_STORAGE" == true ]]; then
  TF_ARGS+=(-var="create_filestore=true")
fi
if [[ "$STARTUP_SMOKE" == true ]]; then
  TF_ARGS+=(
    -var="startup_smoke=true"
    -var="startup_smoke_unit=${SMOKE_UNIT}"
    -var="startup_smoke_max_pages=${SMOKE_PAGES}"
    -var="startup_smoke_timeout_seconds=$(duration_to_seconds "$SMOKE_TIMEOUT")"
    -var="create_artifact_bucket=true"
    -var="artifact_bucket_force_destroy=true"
  )
fi

if [[ "$RUN_INIT" == true ]]; then
  terraform -chdir="$TF_DIR" init
fi

if [[ "$RUN_APPLY" == true ]]; then
  APPLY_ARGS=("${TF_ARGS[@]}")
  if [[ "$AUTO_APPROVE" == true ]]; then
    APPLY_ARGS+=(-auto-approve)
  fi
  terraform -chdir="$TF_DIR" apply "${APPLY_ARGS[@]}"
fi

terraform -chdir="$TF_DIR" output -raw ansible_inventory > "${ANSIBLE_DIR}/inventory.ini"
echo "Wrote ${ANSIBLE_DIR}/inventory.ini"

download_startup_smoke_artifacts() {
  local bucket="$1"
  local log_object="$2"
  local bundle_object="$3"
  local status_object="$4"
  local output_dir="$5"

  mkdir -p "$output_dir"
  gcloud storage cp "gs://${bucket}/${status_object}" "${output_dir}/status.json" >/dev/null 2>&1 || true
  gcloud storage cp "gs://${bucket}/${log_object}" "${output_dir}/startup.log" >/dev/null 2>&1 || true
  gcloud storage cp "gs://${bucket}/${bundle_object}" "${output_dir}/bundle.tgz" >/dev/null 2>&1 || true
  echo "Startup-smoke artifacts: ${output_dir}"
}

poll_startup_smoke() {
  local bucket status_object log_object bundle_object status_uri output_dir tmp_status
  local startup_timeout_seconds deadline

  bucket="$(terraform -chdir="$TF_DIR" output -raw artifact_bucket)"
  status_object="$(terraform -chdir="$TF_DIR" output -raw startup_smoke_status_object)"
  log_object="$(terraform -chdir="$TF_DIR" output -raw startup_smoke_log_object)"
  bundle_object="$(terraform -chdir="$TF_DIR" output -raw startup_smoke_bundle_object)"
  status_uri="gs://${bucket}/${status_object}"
  output_dir="${ARTIFACT_DIR}/$(date -u +%Y%m%dT%H%M%SZ)"
  tmp_status="${output_dir}/status.json.tmp"
  startup_timeout_seconds="$(duration_to_seconds "$STARTUP_TIMEOUT")"
  deadline=$((SECONDS + startup_timeout_seconds))

  mkdir -p "$output_dir"
  echo "Waiting up to ${STARTUP_TIMEOUT} for startup-smoke status: ${status_uri}"

  while (( SECONDS < deadline )); do
    if gcloud storage cat "$status_uri" > "$tmp_status" 2>/dev/null; then
      mv "$tmp_status" "${output_dir}/status.json"
      if grep -q '"status"[[:space:]]*:[[:space:]]*"succeeded"' "${output_dir}/status.json"; then
        download_startup_smoke_artifacts "$bucket" "$log_object" "$bundle_object" "$status_object" "$output_dir"
        return 0
      fi
      if grep -q '"status"[[:space:]]*:[[:space:]]*"failed"' "${output_dir}/status.json"; then
        download_startup_smoke_artifacts "$bucket" "$log_object" "$bundle_object" "$status_object" "$output_dir"
        cat "${output_dir}/status.json" >&2
        return 1
      fi
    fi
    sleep 15
  done

  echo "Timed out waiting for startup-smoke status: ${status_uri}" >&2
  download_startup_smoke_artifacts "$bucket" "$log_object" "$bundle_object" "$status_object" "$output_dir"
  return 124
}

STARTUP_STATUS=0
if [[ "$STARTUP_SMOKE" == true ]]; then
  set +e
  poll_startup_smoke
  STARTUP_STATUS=$?
  set -e
fi

ANSIBLE_STATUS=0
if [[ "$RUN_ANSIBLE" == true ]]; then
  set +e
  (
    cd "$ANSIBLE_DIR"
    echo "Waiting for SSH port readiness..."
    SSH_HOSTS=$(
      awk '
        /^\[hvh_workers\]/ { in_group=1; next }
        /^\[/ { in_group=0 }
        in_group && NF {
          for (i = 1; i <= NF; i++) {
            if ($i ~ /^ansible_host=/) {
              sub(/^ansible_host=/, "", $i)
              print $i
            }
          }
        }
      ' inventory.ini
    )
    WAIT_DEADLINE=$((SECONDS + 240))
    for SSH_HOST in $SSH_HOSTS; do
      until timeout 5 bash -c "</dev/tcp/${SSH_HOST}/22" >/dev/null 2>&1; do
        if (( SECONDS >= WAIT_DEADLINE )); then
          echo "Timed out waiting for SSH on ${SSH_HOST}" >&2
          exit 124
        fi
        sleep 5
      done
    done
    ANSIBLE_ARGS=(-i inventory.ini playbooks/setup_and_run.yml)
    if [[ "$SMOKE_TEST" == true ]]; then
      ANSIBLE_ARGS+=(
        -e "smoke_test=true"
        -e "smoke_unit=${SMOKE_UNIT}"
        -e "smoke_max_pages=${SMOKE_PAGES}"
      )
      timeout "$SMOKE_TIMEOUT" ansible-playbook "${ANSIBLE_ARGS[@]}"
    else
      ansible-playbook "${ANSIBLE_ARGS[@]}"
    fi
  )
  ANSIBLE_STATUS=$?
  set -e
fi

DESTROY_STATUS=0
if [[ "$DESTROY_AFTER" == true ]]; then
  DESTROY_ARGS=("${TF_ARGS[@]}")
  if [[ "$AUTO_APPROVE" == true ]]; then
    DESTROY_ARGS+=(-auto-approve)
  fi
  set +e
  terraform -chdir="$TF_DIR" destroy "${DESTROY_ARGS[@]}"
  DESTROY_STATUS=$?
  set -e
fi

if [[ "$STARTUP_STATUS" -ne 0 ]]; then
  exit "$STARTUP_STATUS"
fi
if [[ "$ANSIBLE_STATUS" -ne 0 ]]; then
  exit "$ANSIBLE_STATUS"
fi
if [[ "$DESTROY_STATUS" -ne 0 ]]; then
  exit "$DESTROY_STATUS"
fi
