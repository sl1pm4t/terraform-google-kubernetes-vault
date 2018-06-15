variable google_project {
  description = "The Google Cloud Project ID"
}

variable google_region {
  description = "The Google Cloud region where resource will be created"
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

variable "google_storage_bucket_roles" {
  type = "list"

  default = [
    "roles/storage.legacyBucketReader",
    "roles/storage.objectAdmin",
  ]
}

variable "google_kms_crypto_key_roles" {
  type = "list"

  default = [
    "roles/cloudkms.cryptoKeyEncrypterDecrypter",
  ]
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
  default     = "0.1.0"
}

variable vault_image_repository {
  description = "The docker image repository of the `vault` image"
  default     = "registry.hub.docker.com/library/vault"
}

variable vault_image_tag {
  description = "Docker image tag of 'vault' container"
  default     = "0.10.1"
}

variable vault_replica_count {
  description = "The number of vault replicas to deploy"
  default     = "3"
}
