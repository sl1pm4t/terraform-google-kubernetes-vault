# Generate self-signed TLS certificates.
resource "tls_private_key" "vault_ca" {
  count     = "${local.create_tls_resources}"
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "vault_ca" {
  count = "${local.create_tls_resources}"

  key_algorithm   = "${tls_private_key.vault_ca.algorithm}"
  private_key_pem = "${tls_private_key.vault_ca.private_key_pem}"

  subject {
    common_name  = "vault-ca.local"
    organization = "HashiCorp Vault"
  }

  validity_period_hours = 8760
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "digital_signature",
    "key_encipherment",
  ]
}

# Create the Vault server certificates
resource "tls_private_key" "vault" {
  count = "${local.create_tls_resources}"

  algorithm = "RSA"
  rsa_bits  = "2048"
}

# Create the request to sign the cert with our CA
resource "tls_cert_request" "vault" {
  count = "${local.create_tls_resources}"

  key_algorithm   = "${tls_private_key.vault.algorithm}"
  private_key_pem = "${tls_private_key.vault.private_key_pem}"

  dns_names = [
    "vault",
    "vault.local",
    "vault.${var.kubernetes_namespace}.svc.cluster.local",
    "localhost",
  ]

  subject {
    common_name  = "vault.local"
    organization = "HashiCorp Vault"
  }
}

# Now sign the cert
resource "tls_locally_signed_cert" "vault" {
  count = "${local.create_tls_resources}"

  cert_request_pem = "${tls_cert_request.vault.cert_request_pem}"

  ca_key_algorithm   = "${tls_private_key.vault_ca.algorithm}"
  ca_private_key_pem = "${tls_private_key.vault_ca.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.vault_ca.cert_pem}"

  validity_period_hours = 8760

  allowed_uses = [
    "cert_signing",
    "client_auth",
    "digital_signature",
    "key_encipherment",
    "server_auth",
  ]
}
