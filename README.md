# Vault on Kubernetes Terraform Module

Deploy a self contained vault cluster to Kubernetes on GCP.

Based on [Kelsey Hightower](https://github.com/kelseyhightower/vault-on-google-kubernetes-engine) and [Seth Vargo's](https://github.com/sethvargo/vault-on-gke/) work with the following differences:
- does not create a Google project
- does not create a Kubernetes cluster

## Feature Highlights

* **Vault HA** - The Vault cluster is deployed in HA mode backed by Google Cloud Storage

* **Production Hardened** - Vault is deployed according to the production hardening guide.

* **Auto-Init and Unseal** - Vault is automatically initialized and unsealed at runtime. The unseal keys are encrypted with Google Cloud KMS and stored in Google Cloud Storage

## Inputs

| Name                              | Description                                                                                                                                                                                                                                           |  Type  |                    Default                     | Required |
| --------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :----: | :--------------------------------------------: | :------: |
| google_kms_crypto_key_roles       |                                                                                                                                                                                                                                                       |  list  |                    `<list>`                    |    no    |
| google_project                    | The Google Cloud Project ID                                                                                                                                                                                                                           | string |                       -                        |   yes    |
| google_region                     | The Google Cloud region where resource will be created                                                                                                                                                                                                | string |                       -                        |   yes    |
| google_service_account_email      | Optionally provide a pre-existing service account for Vault                                                                                                                                                                                           | string |                       ``                       |    no    |
| google_service_account_iam_roles  |                                                                                                                                                                                                                                                       |  list  |                    `<list>`                    |    no    |
| google_storage_bucket_name        | Optionally provide a pre-existing GCS bucket where Vault will use as it's storage backend. If supplied, it is up to the user to ensure the Vault GCP Service Account has appropriate permissions on the bucket (see var.google_storage_bucket_roles). | string |                       ``                       |    no    |
| google_storage_bucket_roles       |                                                                                                                                                                                                                                                       |  list  |                    `<list>`                    |    no    |
| istio_mode                        | Flag to indicate if Istio is enable for this deployment. With Istio sidecar injection Vault listens on plaintext HTTP only, and uses the Istio sidecar to encrypt traffic.                                                                            |  bool  |                     false                      |    no    |
| kubernetes_namespace              | The Kubernetes namespace where Vault resources will be deployed.                                                                                                                                                                                      | string |                   `default`                    |    no    |
| vault_image_repository            | The docker image repository of the `vault` image                                                                                                                                                                                                      | string |    `registry.hub.docker.com/library/vault`     |    no    |
| vault_image_tag                   | Docker image tag of 'vault' container                                                                                                                                                                                                                 | string |                    `1.1.0`                     |    no    |
| vault_init_image_repository       | The docker image repository of the `vault-init` image                                                                                                                                                                                                 | string | `registry.hub.docker.com/mmorrison/vault-init` |    no    |
| vault_init_image_tag              | Docker image tag of 'vault-init' container                                                                                                                                                                                                            | string |                    `2.0.2`                     |    no    |
| vault_load_balancer_fqdn          | FQDN entry that points to the Vault Load Balancer                                                                                                                                                                                                     | string |                       ``                       |    no    |
| vault_load_balancer_ip            | Reserved IP address that will be used by Vault Kubernetes Service                                                                                                                                                                                     | string |                       ``                       |    no    |
| vault_load_balancer_is_internal   | Set to true to create an Internal Load Balancer + IP Reservation                                                                                                                                                                                      |  bool  |                      false                     |    no    |
| vault_load_balancer_ip_subnetwork | VPC Subnetwork name when IP will be reserved. Must be set when 'vault_load_balancer_type' == 'INTERNAL'.                                                                                                                                              | string |                       ``                       |    no    |
| vault_replica_count               | The number of vault replicas to deploy                                                                                                                                                                                                                | string |                      `3`                       |    no    |
| vault_request_cpu                 | Kubernetes CPU Request for Vault pods                                                                                                                                                                                                                 | string |                     `500m`                     |    no    |
| vault_request_memory              | Kubernetes Memory Request for Vault pods                                                                                                                                                                                                              | string |                     `256Mi`                    |    no    |
| vault_tls_cert                    | The Base64 encoded TLS certificate for vault server. If none is supplied, a CA will be created and used to sign a generated certificate.                                                                                                              | string |                       ``                       |    no    |
| vault_tls_key                     | The Base64 encoded TLS key for vault server. If none is supplied, a private key will be generated.                                                                                                                                                    | string |                       ``                       |    no    |
| vault_service_type                | One of 'LoadBalancer', 'ClusterIP' OR 'NodePort'                                                                                                                                                                                                      | string |                   `NodePort`                   |    no    |

## Outputs

| Name                  | Description                                                                                                        |
| --------------------- | ------------------------------------------------------------------------------------------------------------------ |
| address               | Address of the load balancer                                                                                       |
| env                   | Script which exports this Vault to the environment variables, e.g. `VAULT_ADDR`, `VAULT_TOKEN`, and `VAULT_CAPATH` |
| region                | Google Region of this module                                                                                       |
| token                 | Vault Root Token                                                                                                   |
| token_decrypt_command | Script which extracts the encrypted Vault Root Token                                                               |
| vault_ca_pem          | TLS self-signed certificate PEM                                                                                    |


Example:

```
# Load environment variables terraform
# assuming:  module "kubernetes-vault" 

$ eval "$(terraform output -module=kubernetes-vault env)"
$ vault status
```

