# Provision IP
resource "google_compute_address" "vault" {
  name    = "vault-lb"
  region  = "${var.google_region}"
  project = "${var.google_project}"
}
