resource kubernetes_service vault {
  metadata {
    name      = "vault"
    namespace = "${var.kubernetes_namespace}"

    labels {
      app = "vault"
    }
  }

  spec {
    type             = "LoadBalancer"
    load_balancer_ip = "${coalesce(var.vault_load_balancer_ip, join("",google_compute_address.vault.*.address))}"

    selector {
      app = "vault"
    }

    port {
      name        = "vault-port"
      port        = 8200
      target_port = 8200
      protocol    = "TCP"
    }
  }
}

resource kubernetes_service vault_cluster {
  metadata {
    name      = "vault-cluster"
    namespace = "${var.kubernetes_namespace}"

    labels {
      app = "vault-cluster"
    }
  }

  spec {
    type = "ClusterIP"

    selector {
      app = "vault"
    }

    port {
      name     = "cluster-port"
      port     = 8201
      protocol = "TCP"
    }
  }
}
