output "region" {
  value = "${var.google_region}"
}

output "address" {
  value = "${local.load_balancer_address}"
}

data "template_file" "env" {
  template = <<EOF
  
export VAULT_ADDR="https://$${addr}"
export VAULT_TOKEN="$${token}"

cat '$${ca}' > vault_ca.pem

export VAULT_CAPATH=vault_ca.pem
EOF

  vars {
    addr  = "${local.load_balancer_address}"
    token = "${data.google_kms_secret.root_token.plaintext}"
    ca    = "${join("", tls_self_signed_cert.vault_ca.*.cert_pem)}"
  }
}

output "env" {
  value = "${coalesce(data.template_file.env.rendered, "")}"
}

output "token" {
  value = "${data.google_kms_secret.root_token.plaintext}"
}

output "token_decrypt_command" {
  value = "gsutil cat gs://${google_storage_bucket.vault.name}/root-token.enc | base64 --decode | gcloud kms decrypt --project ${var.google_project} --location ${var.google_region} --keyring ${google_kms_key_ring.vault.name} --key ${google_kms_crypto_key.vault_init.name} --ciphertext-file - --plaintext-file -"
}

output "vault_ca_pem" {
  value = "${join("", tls_self_signed_cert.vault_ca.*.cert_pem)}"
}
