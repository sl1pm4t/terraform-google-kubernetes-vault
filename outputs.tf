output "region" {
  value = "${var.google_region}"
}

output "address" {
  value = "${coalesce(var.vault_load_balancer_ip, join("", google_compute_address.vault.*.address))}"
}

data "template_file" "env" {
  template = <<EOF
  
export VAULT_ADDR="https://$${addr}:8200"
export VAULT_TOKEN="$${token}"
$${ca}
  
EOF

  vars {
    addr  = "${google_compute_address.vault.address}"
    token = "${data.google_kms_secret.root_token.plaintext}"
    ca    = "${join("", formatlist("export VAULT_CAPATH=%s", local_file.vault_ca.*.filename))}"
  }
}

output "env" {
  value = "${data.template_file.env.rendered}"
}
