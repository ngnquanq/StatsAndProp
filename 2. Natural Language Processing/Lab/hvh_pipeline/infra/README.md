# HVH GCE worker setup

This folder provisions short-lived Google Compute Engine workers with Terraform
and runs the API OCR pipeline with Ansible. No credentials are committed here.

## 1. Prepare local credentials

Authenticate Terraform with one of the standard Google methods:

```bash
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

Or later set `GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json`.

Create an SSH key if needed:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/hvh_gce -C hvh-gce
```

## 2. Provision workers

```bash
cd hvh_pipeline/infra/terraform
cp terraform.tfvars.example terraform.tfvars
# edit project_id, ssh_user, public_key_path, private_key_path
terraform init
terraform apply
terraform output -raw ansible_inventory > ../ansible/inventory.ini
```

Default worker count is 4. For the full batch after lab approval, set
`worker_count = 15` or `20`.

Before running Ansible, commit and push this infrastructure change; the workers
clone `repo_url` from GitHub and need the `--shard N/TOTAL` pipeline support.

## Quick run script

After `infra/terraform/terraform.tfvars` is filled in, this wrapper provisions
workers, writes the Ansible inventory, and runs the OCR playbook:

```bash
infra/run_gce_workers.sh --workers 20 --auto-approve
```

For the current SSH issue, use startup-script smoke mode. This avoids Ansible
and runs the capped smoke workload from the VM boot script, then downloads the
status/log/bundle locally before destroy:

```bash
infra/run_gce_workers.sh --startup-smoke --smoke-unit HVH_100 --smoke-pages 1 --auto-approve --destroy-after
```

Downloaded smoke files are written under `infra/artifacts/smoke/<timestamp>/`:
`status.json`, `startup.log`, and `bundle.tgz` when the VM produced a bundle.

For one shared Google Cloud filesystem mounted by every worker, enable
Filestore:

```bash
infra/run_gce_workers.sh --workers 20 --shared-storage --auto-approve
```

Filestore makes `images/`, `cache/`, and `output/` shared NFS directories under
`/mnt/hvh_shared` on every worker. It is useful for a coordinated full run, but
it has a 1 TiB minimum on the default `BASIC_HDD` tier, so use plain GCS bundles
for small tests.

## 3. Run OCR

The Ansible playbook clones the current GitHub repo on each worker, installs the
minimal Python packages needed for API OCR, downloads that worker's image shard
(both the default ~700px scans and the `/large/` ~2000px scans used by the
red-ink punctuation track — disable the latter with `-e run_download_large=false`),
and runs API OCR for the same shard. Red-mark detection itself
(`punct_detect.py`) is *not* run on workers: it needs the `.local.json` line
geometry from the GPU machine, so it runs centrally after bundles are merged. When shared storage is enabled, the playbook
mounts Filestore first and links the repo's `images/`, `cache/`, and `output/`
directories to that shared filesystem.

```bash
cd ../ansible
ansible-playbook playbooks/setup_and_run.yml
```

If the CLC site starts requiring login, export credentials locally before the
playbook run. Ansible passes them as environment variables; they are not stored
in Terraform state.

```bash
export KHN_USERNAME='...'
export KHN_PASSWORD='...'
ansible-playbook playbooks/setup_and_run.yml
```

## 4. Store and collect caches

By default, the setup playbook archives each worker's `cache/` and `output/`
directories and uploads the bundle to the Terraform-created GCS bucket. With
shared Filestore enabled, workers write to the same filesystem and the first
worker uploads one shared `hvh-shared-cache-output.tgz` bundle instead:

```bash
terraform -chdir=../terraform output artifact_bucket
# objects look like: gs://BUCKET/runs/hvh-api-ocr/hvh-worker-01-shard-1-of-20.tgz
```

The upload uses the worker VM service account and the metadata service, so no
GCP key file is copied to the workers. Terraform grants that service account
`roles/storage.objectAdmin` on the artifact bucket.

You can still fetch bundles over SSH if needed:

```bash
ansible-playbook playbooks/fetch_cache.yml
```

That writes compressed per-worker cache bundles under
`hvh_pipeline/infra/artifacts/`. Extract and merge the `cache/` folders into the
main `hvh_pipeline/cache/`; API cache files are named `page_NNN.json` and do not
collide with local candidate files.

## 5. Destroy workers

```bash
cd ../terraform
terraform destroy
```

Do this as soon as the cache bundles are collected.
