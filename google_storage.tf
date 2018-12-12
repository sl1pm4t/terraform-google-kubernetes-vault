# Create the storage bucket
resource "google_storage_bucket" "vault" {
  name          = "${local.vault_resource_name}"
  project       = "${var.google_project}"
  force_destroy = true
  storage_class = "MULTI_REGIONAL"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }

    condition {
      num_newer_versions = 3
    }
  }
}

# Grant service account access to the storage bucket
resource "google_storage_bucket_iam_member" "vault_server" {
  count  = "${length(var.google_storage_bucket_roles)}"
  bucket = "${google_storage_bucket.vault.name}"
  role   = "${element(var.google_storage_bucket_roles, count.index)}"
  member = "serviceAccount:${coalesce(var.google_service_account_email, google_service_account.vault_server.email)}"
}
