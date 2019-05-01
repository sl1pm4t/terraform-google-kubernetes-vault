output "region" {
  value = "${var.google_region}"
}

output "address" {
  value = "${coalesce(var.vault_load_balancer_ip, join("", google_compute_address.vault.*.address))}"
}

data "template_file" "env" {
  template = <<EOF
  
export VAULT_ADDR="https://$${addr}"
export VAULT_TOKEN="$${token}"
$${ca}
  
EOF

  vars {
    addr  = "${local.load_balancer_address}"
    token = "${data.google_kms_secret.root_token.plaintext}"
    ca    = "${join("", formatlist("export VAULT_CAPATH=%s", local_file.vault_ca.*.filename))}"
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
