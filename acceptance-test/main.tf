variable google_project {
  default = "not-a-real-project"
}

variable google_region {
  default = "us-west1"
}

variable kube_context {
  default = "no-context"
}

provider google {
  project = "${var.google_project}"
  region  = "${var.google_region}"
}

provider kubernetes {
  config_context   = "${var.kube_context}"
  load_config_file = false
}

resource kubernetes_namespace vault {
  metadata {
    name = "vault-acc-test"
  }
}

module vault {
  source = "../"

  google_project       = "${var.google_project}"
  google_region        = "${var.google_region}"
  kubernetes_namespace = "${kubernetes_namespace.vault.id}"
}

output address {
  value = "${module.vault.address}"
}

output env_export {
  value = "${module.vault.env}"
}
