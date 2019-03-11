# Optionally reserve External IP Address
resource "google_compute_address" "vault" {
  count = "${local.create_load_balancer_address}"

  name         = "${local.vault_resource_name}-lb"
  region       = "${var.google_region}"
  project      = "${var.google_project}"
  address_type = "${var.vault_load_balancer_is_internal ? "INTERNAL": ""}"
  subnetwork   = "${var.vault_load_balancer_ip_subnetwork}"
}
