#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  infra/collect_run.sh [--status | --watch [--watch-timeout T]] [--merge] [--artifact-dir D]

Monitors a --startup-run fleet and merges its GCS bundles into the pipeline.

  --status         Print one status table for all workers and exit (default).
  --watch          Poll worker status every 60s until every worker succeeded
                   or failed (or --watch-timeout expires), then download all
                   bundles.
  --watch-timeout T  Give up watching after T (default 6h; s/m/h suffix).
  --merge          After download, extract every bundle and merge cache/ and
                   images_large/ into the pipeline (existing local files win;
                   output/ is skipped — regenerate with run_pipeline.py --reseg).
  --artifact-dir D Download directory. Default: infra/artifacts/run/<timestamp>
EOF
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="${SCRIPT_DIR}/terraform"
PIPELINE_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
MODE="status"
MERGE=false
WATCH_TIMEOUT="6h"
ARTIFACT_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --status) MODE="status"; shift ;;
    --watch) MODE="watch"; shift ;;
    --watch-timeout) WATCH_TIMEOUT="${2:?--watch-timeout requires a value}"; shift 2 ;;
    --merge) MERGE=true; shift ;;
    --artifact-dir) ARTIFACT_DIR="${2:?--artifact-dir requires a value}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

duration_to_seconds() {
  local value="${1:?duration is required}"
  case "$value" in
    *s) echo "${value%s}" ;;
    *m) echo $(( ${value%m} * 60 )) ;;
    *h) echo $(( ${value%h} * 3600 )) ;;
    *[!0-9]*) echo "Unsupported duration: $value" >&2; exit 2 ;;
    *) echo "$value" ;;
  esac
}

BUCKET="$(terraform -chdir="$TF_DIR" output -raw artifact_bucket)"
PREFIX="$(terraform -chdir="$TF_DIR" output -raw startup_run_prefix)"
if [[ -z "$PREFIX" ]]; then
  echo "startup_run_prefix is empty — was the fleet applied with --startup-run?" >&2
  exit 1
fi
mapfile -t WORKERS < <(terraform -chdir="$TF_DIR" output -json startup_run_workers \
  | python3 -c 'import json, sys; print("\n".join(json.load(sys.stdin)))')
if [[ "${#WORKERS[@]}" -eq 0 ]]; then
  echo "No startup-run workers in Terraform state." >&2
  exit 1
fi

# Prints one line per worker; returns 0 when every worker reached a final
# state, 1 while any is still pending/running.
print_status() {
  local all_final=0
  printf '%-16s %-10s %-8s %-8s %-8s %s\n' WORKER STATUS IMAGES LARGE CACHE TIMESTAMP
  for w in "${WORKERS[@]}"; do
    local raw
    if raw="$(gcloud storage cat "gs://${BUCKET}/${PREFIX}/${w}.status.json" 2>/dev/null)"; then
      if ! printf '%s' "$raw" | python3 -c "
import json, sys
w = sys.argv[1]
d = json.load(sys.stdin)
print(f'{w:<16} {str(d.get(\"status\",\"?\")):<10} {str(d.get(\"images\",\"-\")):<8} '
      f'{str(d.get(\"images_large\",\"-\")):<8} {str(d.get(\"cache_files\",\"-\")):<8} '
      f'{d.get(\"timestamp\",\"\")}')
sys.exit(0 if d.get('status') in ('succeeded', 'failed') else 3)
" "$w"; then
        all_final=1
      fi
    else
      printf '%-16s %-10s\n' "$w" "pending"
      all_final=1
    fi
  done
  return "$all_final"
}

download_bundles() {
  if [[ -z "$ARTIFACT_DIR" ]]; then
    ARTIFACT_DIR="${SCRIPT_DIR}/artifacts/run/$(date -u +%Y%m%dT%H%M%SZ)"
  fi
  mkdir -p "$ARTIFACT_DIR"
  echo "Downloading bundles to ${ARTIFACT_DIR}"
  for w in "${WORKERS[@]}"; do
    gcloud storage cp "gs://${BUCKET}/${PREFIX}/${w}.tgz" "${ARTIFACT_DIR}/" 2>/dev/null \
      || echo "  ${w}: no bundle yet"
    gcloud storage cp "gs://${BUCKET}/${PREFIX}/${w}.log" "${ARTIFACT_DIR}/" 2>/dev/null || true
    gcloud storage cp "gs://${BUCKET}/${PREFIX}/${w}.status.json" "${ARTIFACT_DIR}/" 2>/dev/null || true
  done
}

merge_bundles() {
  local staging
  staging="$(mktemp -d)"
  trap 'rm -rf "$staging"' RETURN
  for tgz in "$ARTIFACT_DIR"/*.tgz; do
    [[ -f "$tgz" ]] || continue
    local name
    name="$(basename "$tgz" .tgz)"
    mkdir -p "$staging/$name"
    tar -xzf "$tgz" -C "$staging/$name"
    for dir in cache images_large; do
      if [[ -d "$staging/$name/$dir" ]]; then
        rsync -a --ignore-existing "$staging/$name/$dir/" "$PIPELINE_DIR/$dir/"
      fi
    done
    echo "  merged $name"
  done
  echo "Merged into ${PIPELINE_DIR}/cache and ${PIPELINE_DIR}/images_large."
  echo "Regenerate deliverables with: python run_pipeline.py --reseg [--punct]"
}

case "$MODE" in
  status)
    print_status || true
    ;;
  watch)
    deadline=$((SECONDS + $(duration_to_seconds "$WATCH_TIMEOUT")))
    while true; do
      echo "=== $(date -Iseconds)"
      if print_status; then
        echo "All workers reached a final state."
        break
      fi
      if (( SECONDS >= deadline )); then
        echo "Watch timeout (${WATCH_TIMEOUT}) reached; downloading whatever exists." >&2
        break
      fi
      sleep 60
    done
    download_bundles
    ;;
esac

if [[ "$MERGE" == true ]]; then
  if [[ -z "$ARTIFACT_DIR" || ! -d "$ARTIFACT_DIR" ]]; then
    download_bundles
  fi
  merge_bundles
fi
