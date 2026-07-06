# HVH Budget Guard

This directory contains a monthly Google Cloud budget guard for the HVH OCR worker project.

It creates:

- a Pub/Sub topic in a separate control project;
- a Cloud Run Function that handles budget notifications;
- a monthly budget scoped to the target HVH project;
- IAM grants for the function runtime service account.

At the hard threshold, the function deletes resources labeled `app=hvh-ocr` and then disables billing for the target project. Budget notifications can lag, so this is not an exact hard cap, but it is the practical monthly kill switch.

## Prerequisites

Refresh local credentials first:

```bash
gcloud auth login
```

Use a dedicated target project for the HVH workers and a separate control project for the function.

## Setup

```bash
infra/budget_guard/setup_budget_guard.sh   --target-project HVH_WORKER_PROJECT   --control-project BILLING_CONTROL_PROJECT   --billing-account 000000-000000-000000   --budget 100
```

To also delete labeled artifact buckets and their objects:

```bash
infra/budget_guard/setup_budget_guard.sh   --target-project HVH_WORKER_PROJECT   --control-project BILLING_CONTROL_PROJECT   --billing-account 000000-000000-000000   --budget 100   --delete-gcs
```

`--delete-gcs` is intentionally opt-in because it removes OCR artifacts.
