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
  type = object({
    org-admin = list(string)
  })
  description = "GitHub teams to use for Dex OIDC"
}

variable "argocd_oidc_tls_skip_verify" {
  type        = bool
  description = "Skip TLS verification for Argo OIDC provider"
  default     = false
}

variable "bitwarden_token" {
  type        = string
  description = "Bitwarden Secret Manager token"
  sensitive   = true
}

variable "cluster_issuer" {
  type        = string
  description = "Cluster issuer to use for certificate"
  default     = "letsencrypt-staging"
}

variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
}

variable "domain" {
  type        = string
  description = "Domain to use - this may be a top-level or subdomain"
}

variable "kubeconfig_path" {
  type        = string
  description = "Kubeconfig for the cluster"
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

variable "infisical_environment_slug" {
  type        = string
  description = "Infisical environment slug"
}

variable "infisical_project_id" {
  type        = string
  description = "Infisical project ID"
  sensitive   = true
}
