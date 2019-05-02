# Generate a random id name to use in resource names
resource "random_string" "random" {
  length  = "8"
  special = false
  upper   = false
}

locals {
  create_load_balancer_address = "${length(var.vault_load_balancer_ip) == 0 ? 1 : 0}"

  load_balancer_address = "${coalesce(
      var.vault_load_balancer_fqdn,
      var.vault_load_balancer_ip,
      join("", google_compute_address.vault.*.address)
  )}"

  create_service_account = "${length(var.google_service_account_email) == 0 ? 1 : 0}"
  create_tls_resources   = "${length(var.vault_tls_cert) == 0 ? 1 : 0}"
  vault_resource_name    = "vault-${random_string.random.result}"
}

# TLS locals
locals {
  decoded_tls_cert = "${ length(var.vault_tls_cert) > 0 ? base64decode(var.vault_tls_cert) : ""}"
  decoded_tls_key  = "${ length(var.vault_tls_key) > 0 ? base64decode(var.vault_tls_key) : ""}"

  generated_tls_cert_chain = "${join("", tls_locally_signed_cert.vault.*.cert_pem)}\n${join("", tls_self_signed_cert.vault_ca.*.cert_pem)}"
  generated_tls_key        = "${join("", tls_private_key.vault.*.private_key_pem)}"
}

# Istio Support
locals {
  vault_protocol       = "${var.istio_mode ? "http" : "https"}"
  vault_protocol_upper = "${var.istio_mode ? "HTTP" : "HTTPS"}"

  // In istio mode, ensure Vault only listens on loopback to ensure
  // traffic has passed through the Istio proxy (Envoy)
  vault_listener = "${var.istio_mode ? "127.0.0.1:8200" : "0.0.0.0:8200"}"

  // The istio-proxy will ensure mTLS, so disable at the Vault level
  vault_disable_tls = "${var.istio_mode ? "1" : "0"}"
}
