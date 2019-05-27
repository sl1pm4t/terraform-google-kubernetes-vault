output "region" {
  description = "Google Region of this module"
  value = "${var.google_region}"
}

output "address" {
  description = "Address of the load balancer"
  value = "${local.load_balancer_address}"
}

data "template_file" "env" {
  template = <<EOF
VAULT_CAPATH="$$$${VAULT_CAPATH:-vault_ca.pem}"
export VAULT_ADDR="https://$${addr}"
export VAULT_TOKEN="$${token}"

cat <<EOPEM > $VAULT_CAPATH
$${ca}
EOPEM

export VAULT_CAPATH="$VAULT_CAPATH"
EOF

  vars {
    addr  = "${local.load_balancer_address}"
    token = "${data.google_kms_secret.root_token.plaintext}"
    ca    = "${join("", tls_self_signed_cert.vault_ca.*.cert_pem)}"
  }
}

output "env" {
  description = "Script which exports this Vault to the environment variables, e.g. `VAULT_ADDR`, `VAULT_TOKEN`. The TLS cert will be written to `VAULT_CAPATH`, which can be pre-set or defaults to `vault_ca.pem`."
  value = "${coalesce(data.template_file.env.rendered, "")}"
}

output "token" {
  description = "Vault Root Token"
  value = "${chomp(data.google_kms_secret.root_token.plaintext)}"
}

output "token_decrypt_command" {
  description = "Script which extracts the encrypted Vault Root Token"
  value = "gsutil cat gs://${google_storage_bucket.vault.name}/root-token.enc | base64 --decode | gcloud kms decrypt --project ${var.google_project} --location ${var.google_region} --keyring ${google_kms_key_ring.vault.name} --key ${google_kms_crypto_key.vault_init.name} --ciphertext-file - --plaintext-file -"
}

output "vault_ca_pem" {
  description = "TLS self-signed certificate PEM"
  value = "${join("", tls_self_signed_cert.vault_ca.*.cert_pem)}"
}
