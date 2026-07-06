variable "project_id" {
  description = "Google Cloud project ID."
  type        = string
}

variable "region" {
  description = "Google Cloud region for worker VMs."
  type        = string
  default     = "asia-southeast1"
}

variable "zone" {
  description = "Google Cloud zone for worker VMs."
  type        = string
  default     = "asia-southeast1-a"
}

variable "worker_count" {
  description = "Number of OCR worker VMs to create."
  type        = number
  default     = 4

  validation {
    condition     = var.worker_count >= 1 && var.worker_count <= 50
    error_message = "worker_count must be between 1 and 50."
  }
}

variable "name_prefix" {
  description = "Prefix for worker VM names."
  type        = string
  default     = "hvh-ocr"
}

variable "machine_type" {
  description = "Worker VM machine type. API workers do not need GPUs."
  type        = string
  default     = "e2-small"
}

variable "boot_disk_size_gb" {
  description = "Worker boot disk size in GB."
  type        = number
  default     = 20
}

variable "boot_image" {
  description = "Boot disk image."
  type        = string
  default     = "debian-cloud/debian-12"
}

variable "network" {
  description = "VPC network name or self link."
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "Optional subnetwork name or self link. Leave empty to use the network default."
  type        = string
  default     = ""
}

variable "network_tier" {
  description = "External IP network tier."
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "PREMIUM"], var.network_tier)
    error_message = "network_tier must be STANDARD or PREMIUM."
  }
}

variable "ssh_user" {
  description = "Linux user for SSH and Ansible."
  type        = string
  default     = "hvh"
}

variable "public_key_path" {
  description = "Path to the SSH public key to install on workers."
  type        = string
}

variable "private_key_path" {
  description = "Path to the matching SSH private key for the generated Ansible inventory."
  type        = string
}

variable "ssh_source_ranges" {
  description = "CIDR ranges allowed to SSH to workers. Restrict this to your current public IP when possible."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "create_ssh_firewall" {
  description = "Whether to create an SSH firewall rule for the worker tag."
  type        = bool
  default     = true
}

variable "spot" {
  description = "Use Spot VMs. Cheaper, but workers may be interrupted."
  type        = bool
  default     = false
}

variable "service_account_email" {
  description = "Optional existing service account email to attach to workers. Leave empty to create one."
  type        = string
  default     = ""
}

variable "create_artifact_bucket" {
  description = "Whether Terraform should create the GCS bucket for worker bundles."
  type        = bool
  default     = true
}

variable "artifact_bucket_name" {
  description = "GCS bucket for worker cache/output bundles. Leave empty for PROJECT-PREFIX-artifacts."
  type        = string
  default     = ""
}

variable "artifact_bucket_location" {
  description = "GCS bucket location."
  type        = string
  default     = "ASIA-SOUTHEAST1"
}

variable "artifact_bucket_force_destroy" {
  description = "Allow terraform destroy to delete non-empty artifact bucket. Keep false to protect results."
  type        = bool
  default     = false
}

variable "artifact_prefix" {
  description = "Object prefix inside the artifact bucket."
  type        = string
  default     = "runs/hvh-api-ocr"
}

variable "startup_smoke" {
  description = "Run the capped smoke test from a VM startup script instead of Ansible."
  type        = bool
  default     = false
}

variable "startup_smoke_unit" {
  description = "Unit code for startup-script smoke tests."
  type        = string
  default     = "HVH_100"
}

variable "startup_smoke_max_pages" {
  description = "Maximum pages to process during startup-script smoke tests."
  type        = number
  default     = 1
}

variable "startup_smoke_timeout_seconds" {
  description = "Timeout in seconds for the OCR command inside startup-script smoke tests."
  type        = number
  default     = 600
}

variable "repo_url" {
  description = "Git repository URL cloned by startup-script workers."
  type        = string
  default     = "https://github.com/ngnquanq/StatsAndProp.git"
}

variable "repo_version" {
  description = "Git branch, tag, or ref cloned by startup-script workers."
  type        = string
  default     = "master"
}

variable "repo_sparse_path" {
  description = "Sparse checkout path containing the HVH pipeline."
  type        = string
  default     = "2. Natural Language Processing/Lab/hvh_pipeline"
}


variable "create_filestore" {
  description = "Create a shared Filestore NFS instance for worker images/cache/output."
  type        = bool
  default     = false
}

variable "filestore_name" {
  description = "Filestore instance name. Leave empty for NAME_PREFIX-shared."
  type        = string
  default     = ""
}

variable "filestore_tier" {
  description = "Filestore tier for the shared NFS instance."
  type        = string
  default     = "BASIC_HDD"
}

variable "filestore_capacity_gb" {
  description = "Filestore capacity in GB. BASIC_HDD requires at least 1024 GB."
  type        = number
  default     = 1024

  validation {
    condition     = var.filestore_capacity_gb >= 1024
    error_message = "filestore_capacity_gb must be at least 1024 for BASIC_HDD."
  }
}

variable "filestore_share_name" {
  description = "NFS export name inside Filestore."
  type        = string
  default     = "hvhshare"
}

variable "shared_mount_path" {
  description = "Mount point used by Ansible on each worker."
  type        = string
  default     = "/mnt/hvh_shared"
}
