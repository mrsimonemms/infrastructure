# Copyright 2024 Simon Emms <simon@simonemms.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

variable "argocd_version" {
  type        = string
  description = "Version of ArgoCD to use - defaults to latest"
  default     = null
}

variable "argocd_github_org" {
  type        = string
  description = "GitHub org to use for Dex OIDC"
}

variable "argocd_github_teams" {
  type        = list(string)
  description = "GitHub teams to use for Dex OIDC"
}

variable "argocd_github_client_id" {
  type        = string
  description = "GitHub OIDC client ID for Dex"
  sensitive   = true
}

variable "argocd_github_client_secret" {
  type        = string
  description = "GitHub OIDC client secret for Dex"
  sensitive   = true
}

variable "cluster_issuer" {
  type        = string
  description = "Cluster issuer to use for certificate"
  default     = "letsencrypt-staging"
}

variable "domain" {
  type        = string
  description = "Domain to use - this may be a top-level or subdomain"
}

variable "hcloud_network_name" {
  type        = string
  description = "Name of the network"
}

variable "hcloud_token" {
  sensitive   = true
  type        = string
  description = "Write token for the Hetzner API"
}

variable "hetzner_cloud_config_manager_version" {
  type        = string
  description = "Version of the HCloud CCM to use - defaults to latest"
  default     = null
}

variable "hetzner_csi_driver_version" {
  type        = string
  description = "Tag of the CSI driver to use - defaults to latest"
  default     = null
}

variable "k3s_cluster_cidr" {
  type        = string
  description = "CIDR used for the k3s cluster"
  default     = "10.244.0.0/16"
}

variable "kubeconfig" {
  type        = string
  description = "Kubeconfig for the cluster"
  sensitive   = true
}

variable "kube_context" {
  type        = string
  description = "Kubernetes context to use"
  default     = "default"
}

variable "ingress_nginx_version" {
  type        = string
  description = "Version of Ingress Nginx to install - defaults to latest"
  default     = null
}

variable "infisical_client_id" {
  type        = string
  description = "Infisical client ID"
  sensitive   = true
}

variable "infisical_client_secret" {
  type        = string
  description = "Infisical client secret"
  sensitive   = true
}

variable "load_balancer_location" {
  type        = string
  description = "Location to use for the load balancer"
}

variable "load_balancer_type" {
  type        = string
  description = "Type of load balancer to use"
  default     = "lb11"
}
