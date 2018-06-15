# Vault on Kubernetes Terraform Module

Deploy a self contained vault cluster to Kubernetes on GCP.

Based on [Kelsey Hightower](https://github.com/kelseyhightower/vault-on-google-kubernetes-engine) and [Seth Vargo's](https://github.com/sethvargo/vault-on-gke/) work with the following differences:
- does not create a Google project
- does not create a Kubernetes cluster
- uses the unofficial [terraform-kubernetes-provider](https://github.com/sl1pm4t/terraform-provider-kubernetes) that supports `StatefulSet` resource, instead of `kubectl apply` to deploy Vault.

## Feature Highlights

* **Vault HA** - The Vault cluster is deployed in HA mode backed by Google Cloud Storage

* **Production Hardened** - Vault is deployed according to the production hardening guide.

* **Auto-Init and Unseal** - Vault is automatically initialized and unsealed at runtime. The unseal keys are encrypted with Google Cloud KMS and stored in Google Cloud Storage