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
  --smoke-timeout T  Timeout for smoke Ansible run. Default: 10m.
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

require_command terraform
require_command ansible-playbook
if [[ "$SMOKE_TEST" == true ]]; then
  require_command timeout
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

ANSIBLE_STATUS=0
if [[ "$RUN_ANSIBLE" == true ]]; then
  set +e
  (
    cd "$ANSIBLE_DIR"
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

if [[ "$ANSIBLE_STATUS" -ne 0 ]]; then
  exit "$ANSIBLE_STATUS"
fi
if [[ "$DESTROY_STATUS" -ne 0 ]]; then
  exit "$DESTROY_STATUS"
fi
