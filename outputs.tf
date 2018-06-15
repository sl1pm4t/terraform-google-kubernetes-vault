output "region" {
  value = "${var.google_region}"
}

output "address" {
  value = "${google_compute_address.vault.address}"
}

data template_file env {
  template = <<EOF
####
export VAULT_ADDR="https://$${addr}:8200"
export VAULT_CAPATH="vault_ca.pem"
export VAULT_TOKEN="$${token}"
####
EOF

  vars {
    addr  = "${google_compute_address.vault.address}"
    token = "${data.google_kms_secret.root_token.plaintext}"
  }
}

output "env" {
  value = "${data.template_file.env.rendered}"
}
