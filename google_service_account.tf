# Create the vault service account
resource "google_service_account" "vault_server" {
  count        = "${local.create_service_account}"
  account_id   = "vault-server"
  display_name = "Vault Server"
  project      = "${var.google_project}"
}

# Create a service account key
resource "google_service_account_key" "vault" {
  count              = "${local.create_service_account}"
  service_account_id = "${google_service_account.vault_server.name}"
}

# Add the service account to the project
resource "google_project_iam_member" "service_account" {
  count   = "${local.create_service_account * length(var.google_service_account_iam_roles)}"
  project = "${var.google_project}"
  role    = "${element(var.google_service_account_iam_roles, count.index)}"
  member  = "serviceAccount:${coalesce(var.google_service_account_email, google_service_account.vault_server.email)}"
}
