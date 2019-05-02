resource kubernetes_stateful_set vault {
  metadata {
    name      = "vault"
    namespace = "${var.kubernetes_namespace}"

    labels {
      app = "vault"
    }
  }

  spec {
    service_name = "vault"
    replicas     = "${var.vault_replica_count}"

    selector {
      match_labels {
        app = "vault"
      }
    }

    template {
      metadata {
        name = "vault"

        labels {
          app = "vault"
        }
      }

      spec {
        # affinity {  #   pod_anti_affinity {  #     preferred_during_scheduling_ignored_during_execution {  #       weight = 60

        #       pod_affinity_term {  #         label_selector {  #           match_expressions {  #             key      = "app"  #             operator = "In"  #             values   = ["vault"]  #           }  #         }

        #         topology_key = "kubernetes.io/hostname"  #       }  #     }  #   }  # }

        termination_grace_period_seconds = 10

        container {
          name              = "vault"
          image             = "${var.vault_image_repository}:${var.vault_image_tag}"
          image_pull_policy = "IfNotPresent"

          args = ["server"]

          security_context {
            capabilities {
              add = ["IPC_LOCK"]
            }
          }

          env {
            name = "POD_IP_ADDR"

            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }

          env {
            name = "VAULT_LOCAL_CONFIG"

            value = <<EOF
api_addr     = "https://${local.load_balancer_address}"
cluster_addr = "https://$(POD_IP_ADDR):8201"

ui = true

seal "gcpckms" {
  disabled   = "false" # set to true during migration
  project    = "${google_kms_key_ring.vault.project}"
  region     = "${google_kms_key_ring.vault.location}"
  key_ring   = "${google_kms_key_ring.vault.name}"
  crypto_key = "${google_kms_crypto_key.vault_init.name}"
}

storage "gcs" {
  bucket     = "${google_storage_bucket.vault.name}"
  ha_enabled = "true"
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/etc/vault/tls/vault.crt"
  tls_key_file  = "/etc/vault/tls/vault.key"
  tls_disable_client_certs = "true"
}
EOF
          }

          env {
            name  = "GOOGLE_APPLICATION_CREDENTIALS"
            value = "/etc/vault/google/service-account.json"
          }

          port {
            container_port = 8200
            name           = "https-vault"
            protocol       = "TCP"
          }

          port {
            container_port = 8201
            name           = "tcp-cluster"
            protocol       = "TCP"
          }

          readiness_probe {
            http_get {
              path   = "/v1/sys/health?standbyok=true"
              port   = 8200
              scheme = "HTTPS"

              http_header {
                name  = "Host"
                value = "${local.load_balancer_address}"
              }
            }

            initial_delay_seconds = "5"
            period_seconds        = "5"
          }

          resources {
            requests {
              cpu    = "${var.vault_request_cpu}"
              memory = "${var.vault_request_memory}"
            }
          }

          volume_mount {
            name       = "vault-tls"
            mount_path = "/etc/vault/tls"
          }

          volume_mount {
            name       = "vault-service-account"
            mount_path = "/etc/vault/google"
          }
        }

        container {
          name              = "vault-init"
          image             = "${var.vault_init_image_repository}:${var.vault_init_image_tag}"
          image_pull_policy = "Always"

          resources {
            requests {
              cpu    = "100m"
              memory = "64Mi"
            }
          }

          env {
            name  = "CHECK_INTERVAL"
            value = "30"
          }

          env {
            name  = "GCS_BUCKET_NAME"
            value = "${google_storage_bucket.vault.name}"
          }

          env {
            name  = "KMS_KEY_ID"
            value = "${google_kms_crypto_key.vault_init.name}"
          }

          env {
            name  = "GOOGLE_APPLICATION_CREDENTIALS"
            value = "/etc/vault/google/service-account.json"
          }

          volume_mount {
            name       = "vault-service-account"
            mount_path = "/etc/vault/google"
          }
        }

        volume {
          name = "vault-tls"

          secret {
            secret_name = "vault-tls"
          }
        }

        volume {
          name = "vault-service-account"

          secret {
            secret_name = "vault-service-account"
          }
        }
      }
    }
  }
}
