provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

locals {
  worker_tag                   = "${var.name_prefix}-worker"
  worker_service_account_id    = substr(replace("${var.name_prefix}-worker", "_", "-"), 0, 30)
  worker_service_account_email = var.service_account_email == "" ? google_service_account.worker[0].email : var.service_account_email
  artifact_bucket_name         = var.artifact_bucket_name == "" ? "${var.project_id}-${var.name_prefix}-artifacts" : var.artifact_bucket_name
  filestore_name               = var.filestore_name == "" ? "${var.name_prefix}-shared" : var.filestore_name
  ssh_public_key               = trimspace(file(pathexpand(var.public_key_path)))
  startup_smoke_prefix         = "${var.artifact_prefix}/startup-smoke"
  startup_run_prefix           = "${var.artifact_prefix}/startup-run"
}

resource "google_service_account" "worker" {
  count = var.service_account_email == "" ? 1 : 0

  account_id   = local.worker_service_account_id
  display_name = "HVH OCR worker service account"
}

resource "google_storage_bucket" "artifacts" {
  count = var.create_artifact_bucket ? 1 : 0

  name                        = local.artifact_bucket_name
  location                    = var.artifact_bucket_location
  force_destroy               = var.artifact_bucket_force_destroy
  uniform_bucket_level_access = true

  labels = {
    app  = "hvh-ocr"
    role = "artifacts"
  }
}

resource "google_storage_bucket_iam_member" "worker_artifact_writer" {
  count = var.create_artifact_bucket ? 1 : 0

  bucket = google_storage_bucket.artifacts[0].name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${local.worker_service_account_email}"
}

resource "google_filestore_instance" "shared" {
  count = var.create_filestore ? 1 : 0

  name     = local.filestore_name
  location = var.zone
  tier     = var.filestore_tier

  labels = {
    app  = "hvh-ocr"
    role = "shared-storage"
  }

  file_shares {
    capacity_gb = var.filestore_capacity_gb
    name        = var.filestore_share_name
  }

  networks {
    network = var.network
    modes   = ["MODE_IPV4"]
  }
}

resource "google_compute_firewall" "ssh" {
  count = var.create_ssh_firewall ? 1 : 0

  name          = "${var.name_prefix}-allow-ssh"
  network       = var.network
  source_ranges = var.ssh_source_ranges
  target_tags   = [local.worker_tag]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_instance" "worker" {
  count = var.worker_count

  name         = format("%s-%02d", var.name_prefix, count.index + 1)
  machine_type = var.machine_type
  zone         = var.zone
  tags         = [local.worker_tag]

  labels = {
    app  = "hvh-ocr"
    role = "worker"
  }

  boot_disk {
    initialize_params {
      image = var.boot_image
      size  = var.boot_disk_size_gb
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork == "" ? null : var.subnetwork

    access_config {
      network_tier = var.network_tier
    }
  }

  metadata = merge(
    {
      ssh-keys = "${var.ssh_user}:${local.ssh_public_key}"
    },
    var.startup_run ? {
      startup-script = templatefile("${path.module}/startup_run.sh.tftpl", {
        repo_url            = var.repo_url
        repo_version        = var.repo_version
        repo_sparse_path    = var.repo_sparse_path
        pipeline_dir        = "/opt/StatsAndProp/${var.repo_sparse_path}"
        shard_index         = count.index + 1
        shard_total         = var.worker_count
        run_timeout_seconds = var.startup_run_timeout_seconds
        seed_object         = var.seed_object
        gcs_bucket          = local.artifact_bucket_name
        gcs_prefix          = local.startup_run_prefix
        worker_name         = format("hvh-worker-%02d", count.index + 1)
      })
    } : var.startup_smoke ? {
      startup-script = templatefile("${path.module}/startup_smoke.sh.tftpl", {
        repo_url              = var.repo_url
        repo_version          = var.repo_version
        repo_sparse_path      = var.repo_sparse_path
        pipeline_dir          = "/opt/StatsAndProp/${var.repo_sparse_path}"
        smoke_unit            = var.startup_smoke_unit
        smoke_max_pages       = var.startup_smoke_max_pages
        smoke_timeout_seconds = var.startup_smoke_timeout_seconds
        gcs_bucket            = local.artifact_bucket_name
        gcs_prefix            = local.startup_smoke_prefix
        worker_name           = format("hvh-worker-%02d", count.index + 1)
      })
    } : {}
  )

  scheduling {
    automatic_restart           = var.spot ? false : true
    on_host_maintenance         = var.spot ? "TERMINATE" : "MIGRATE"
    provisioning_model          = var.spot ? "SPOT" : "STANDARD"
    instance_termination_action = var.spot ? "STOP" : null
  }

  service_account {
    email  = local.worker_service_account_email
    scopes = ["cloud-platform"]
  }

  depends_on = [
    google_storage_bucket_iam_member.worker_artifact_writer,
    google_filestore_instance.shared,
  ]
}
