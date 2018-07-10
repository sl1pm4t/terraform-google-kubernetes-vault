# Optionally reserve External IP Address
resource "google_compute_address" "vault" {
  count = "${local.create_load_balancer_address}"

  name    = "vault-lb"
  region  = "${var.google_region}"
  project = "${var.google_project}"
}
