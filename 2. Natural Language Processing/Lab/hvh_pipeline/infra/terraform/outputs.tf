output "worker_ips" {
  description = "Public IP addresses for OCR workers."
  value = {
    for i, instance in google_compute_instance.worker :
    format("hvh-worker-%02d", i + 1) => instance.network_interface[0].access_config[0].nat_ip
  }
}

output "artifact_bucket" {
  description = "GCS bucket where worker bundles are uploaded."
  value       = local.artifact_bucket_name
}

output "worker_service_account" {
  description = "Service account attached to OCR workers."
  value       = local.worker_service_account_email
}

output "filestore_ip" {
  description = "Shared Filestore NFS IP address, when create_filestore is true."
  value       = var.create_filestore ? google_filestore_instance.shared[0].networks[0].ip_addresses[0] : ""
}

output "ansible_inventory" {
  description = "INI inventory for Ansible. Write with: terraform output -raw ansible_inventory > ../ansible/inventory.ini"
  value = join("\n", concat(
    ["[hvh_workers]"],
    [
      for i, instance in google_compute_instance.worker :
      format(
        "hvh-worker-%02d ansible_host=%s ansible_user=%s ansible_ssh_private_key_file=%s shard_index=%d shard_total=%d",
        i + 1,
        instance.network_interface[0].access_config[0].nat_ip,
        var.ssh_user,
        pathexpand(var.private_key_path),
        i + 1,
        var.worker_count
      )
    ],
    [
      "",
      "[hvh_workers:vars]",
      "ansible_python_interpreter=/usr/bin/python3",
      "gcs_bucket=${local.artifact_bucket_name}",
      "gcs_prefix=${var.artifact_prefix}",
      "shared_storage_enabled=${var.create_filestore}",
      "shared_mount_path=${var.shared_mount_path}",
      "filestore_ip=${var.create_filestore ? google_filestore_instance.shared[0].networks[0].ip_addresses[0] : ""}",
      "filestore_share_name=${var.filestore_share_name}",
    ]
  ))
}
