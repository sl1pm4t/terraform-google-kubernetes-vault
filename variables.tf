variable google_project {
  description = "The Google Cloud Project ID"
}

variable google_region {
  description = "The Google Cloud region where resource will be created"
}

variable "google_kms_crypto_key_roles" {
  type = "list"

  default = [
    "roles/cloudkms.cryptoKeyEncrypterDecrypter",
  ]
}

variable google_service_account_email {
  default     = ""
  description = "Optionally provide a pre-existing service account for Vault"
}

variable "google_service_account_iam_roles" {
  type = "list"

  default = [
    "roles/resourcemanager.projectIamAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountKeyAdmin",
    "roles/iam.serviceAccountTokenCreator",
    "roles/iam.serviceAccountUser",
    "roles/viewer",
  ]
}

variable "google_storage_bucket_name" {
  description = "Optionally provide a pre-existing GCS bucket where Vault will use as it's storage backend. If supplied, it is up to the user to ensure the Vault GCP Service Account has appropriate permissions on the bucket (see var.google_storage_bucket_roles)."
  default     = ""
}

variable "google_storage_bucket_roles" {
  description = "List of IAM roles that will be granted to the Vault Service Account on the GCS bucket."
  type        = "list"

  default = [
    "roles/storage.legacyBucketReader",
    "roles/storage.objectAdmin",
  ]
}

variable "istio_mode" {
  description = "Flag to indicate if Istio is enable for this deployment. With Istio sidecar injection Vault listens on plaintext HTTP only, and uses the Istio sidecar to encrypt traffic."
  default     = false
}

variable kubernetes_namespace {
  description = "The Kubernetes namespace where Vault resources will be deployed."
  default     = "default"
}

variable vault_init_image_repository {
  default     = "registry.hub.docker.com/sethvargo/vault-init"
  description = "The docker image repository of the `vault-init` image"
}

variable vault_init_image_tag {
  description = "Docker image tag of 'vault-init' container"
  default     = "1.0.0"
}

variable vault_image_repository {
  description = "The docker image repository of the `vault` image"
  default     = "registry.hub.docker.com/library/vault"
}

variable vault_image_tag {
  description = "Docker image tag of 'vault' container"
  default     = "1.1.0"
}

variable vault_load_balancer_fqdn {
  description = "FQDN entry that points to the Vault Load Balancer"
  default     = ""
}

variable vault_load_balancer_ip {
  description = "Reserved IP address that will be used by Vault Kubernetes Service"
  default     = ""
}

variable vault_load_balancer_is_internal {
  description = "Set to true to create an Internal Load Balancer + IP Reservation"
  default     = false
}

variable vault_load_balancer_ip_subnetwork {
  description = "VPC Subnetwork name when IP will be reserved. Must be set when 'vault_load_balancer_type' == 'INTERNAL'."
  default     = ""
}

variable vault_replica_count {
  type = "string"

  description = <<EOF
The number of vault replicas to deploy. 
Anti-affinity rules spread pods across availablenodes. 
Please use an odd number for better availability.
EOF

  default = "3"
}

variable vault_tls_cert {
  description = "The Base64 encoded TLS certificate for vault server. If none is supplied, a CA will be created and used to sign a generated certificate."
  default     = ""
}

variable vault_tls_key {
  description = "The Base64 encoded TLS key for vault server. If none is supplied, a private key will be generated."
  default     = ""
}

variable vault_request_cpu {
  description = "Kubernetes CPU Request for Vault pods"
  default     = "500m"
}

variable vault_request_memory {
  description = "Kubernetes Memory Request for Vault pods"
  default     = "256Mi"
}

variable vault_service_type {
  description = "One of 'LoadBalancer', 'ClusterIP' OR 'NodePort'"
  default     = "NodePort"
}
