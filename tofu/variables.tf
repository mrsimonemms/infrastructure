# Copyright 2026 Simon Emms <simon@simonemms.com>
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

# ------------------------------------------------------------------------------
# Hetzner Cloud
# ------------------------------------------------------------------------------

variable "hcloud_token" {
  description = "Hetzner Cloud API token with read/write access to the project."
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  description = "Logical name used as a prefix for cloud resources and as the k3s cluster identity."
  type        = string
  default     = "homelab"
}

variable "hetzner_location" {
  description = "Hetzner location for control-plane nodes (e.g. nbg1, fsn1, hel1)."
  type        = string
  default     = "nbg1"
}

variable "hetzner_server_type" {
  description = "Hetzner server type for control-plane nodes."
  type        = string
  default     = "cx22"
}

variable "hetzner_image" {
  description = "Hetzner OS image for control-plane nodes."
  type        = string
  default     = "ubuntu-24.04"
}

variable "node_count" {
  description = "Number of control-plane nodes. 3 is required for embedded etcd HA."
  type        = number
  default     = 3

  validation {
    condition     = var.node_count >= 1 && var.node_count % 2 == 1
    error_message = "node_count must be a positive odd integer (1, 3, 5, ...) for etcd quorum."
  }
}

# ------------------------------------------------------------------------------
# Networking
# ------------------------------------------------------------------------------

variable "network_cidr" {
  description = "CIDR for the Hetzner private network."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR for the control-plane subnet inside network_cidr."
  type        = string
  default     = "10.0.1.0/24"
}

variable "control_plane_ip_offset" {
  description = "Host offset within subnet_cidr for the first control-plane node. Subsequent nodes increment from here."
  type        = number
  default     = 10
}

# ------------------------------------------------------------------------------
# Access control
# ------------------------------------------------------------------------------

variable "ssh_public_keys" {
  description = "OpenSSH public keys that should be authorised to log in as root on every node."
  type        = list(string)
}

variable "allowed_ssh_cidrs" {
  description = "CIDRs allowed to reach SSH (port 22) on the public interface of each node."
  type        = list(string)
}

variable "allowed_kube_api_cidrs" {
  description = "CIDRs allowed to reach the Kubernetes API (port 6443) on the public interface of each node."
  type        = list(string)
}

# ------------------------------------------------------------------------------
# k3s
# ------------------------------------------------------------------------------

variable "k3s_version" {
  description = "Pinned k3s release channel or version (passed to INSTALL_K3S_VERSION)."
  type        = string
  default     = "v1.31.4+k3s1"
}

variable "k3s_tls_sans" {
  description = "Additional DNS names / IPs to add to the API server certificate (e.g. a Cloudflare A record)."
  type        = list(string)
  default     = []
}

variable "cloud_node_labels" {
  description = "Labels applied to every Hetzner control-plane node via k3s --node-label."
  type        = map(string)
  default = {
    "topology.simonemms.com/location"       = "cloud"
    "node-role.simonemms.com/control-plane" = "true"
  }
}

# ------------------------------------------------------------------------------
# Flux bootstrap
# ------------------------------------------------------------------------------

variable "enable_flux_bootstrap" {
  description = "If true, run `flux bootstrap github` against the freshly created cluster."
  type        = bool
  default     = true
}

variable "github_owner" {
  description = "GitHub user or org that owns the Flux repository."
  type        = string
  default     = ""
}

variable "github_repository" {
  description = "Name of the GitHub repository Flux will reconcile from."
  type        = string
  default     = "infrastructure"
}

variable "github_branch" {
  description = "Branch in the GitHub repository Flux will track."
  type        = string
  default     = "main"
}

variable "github_token" {
  description = "GitHub personal access token used by `flux bootstrap` (needs repo scope)."
  type        = string
  default     = ""
  sensitive   = true
}

variable "flux_target_path" {
  description = "Path inside the GitHub repository where Flux writes its own manifests."
  type        = string
  default     = "clusters/homelab"
}

# ------------------------------------------------------------------------------
# Cloudflare (placeholder - no DNS records are created yet)
# ------------------------------------------------------------------------------

variable "cloudflare_api_token" {
  description = "Cloudflare API token. Currently unused; kept here so DNS records can be added later without re-plumbing variables."
  type        = string
  default     = ""
  sensitive   = true
}

# ------------------------------------------------------------------------------
# Local outputs
# ------------------------------------------------------------------------------

variable "kubeconfig_output_path" {
  description = "Local filesystem path where the cluster kubeconfig will be written after bootstrap."
  type        = string
  default     = "./.kube/config"
}
