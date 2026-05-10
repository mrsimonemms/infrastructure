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

# ---- cloud-init / k3s rendering inputs --------------------------------------
# These drive the cloud_init_per_node output and must NOT depend on any
# output of the hetzner module - if they did, the module graph would cycle
# (hetzner consumes cloud_init_per_node, post-cluster resources here consume
# hetzner outputs).

variable "cluster_name" {
  description = "Logical cluster name."
  type        = string
}

variable "control_plane_nodes" {
  description = "Per-node descriptors (index, name, private_ip, is_first_node)."
  type = list(object({
    index         = number
    name          = string
    private_ip    = string
    is_first_node = bool
  }))
}

variable "first_node_private_ip" {
  description = "Private IP of the node that runs `k3s server --cluster-init`. The other nodes join this address."
  type        = string
}

variable "k3s_token" {
  description = "Shared k3s join token (same value for all servers)."
  type        = string
  sensitive   = true
}

variable "k3s_version" {
  description = "Pinned k3s version (passed to INSTALL_K3S_VERSION)."
  type        = string
}

variable "k3s_tls_sans" {
  description = "Additional TLS SANs for the API server certificate."
  type        = list(string)
  default     = []
}

variable "cloud_node_labels" {
  description = "k3s --node-label values applied to every Hetzner control-plane node."
  type        = map(string)
}

variable "ssh_authorized_keys" {
  description = "OpenSSH public keys to install in cloud-init for the root user."
  type        = list(string)
}

# ---- post-cluster inputs ----------------------------------------------------
# These resolve only after `module.hetzner` has applied. They are consumed by
# terraform_data resources in this module, NOT by the cloud_init_per_node
# output, so the resource-level graph stays acyclic.

variable "first_server_public_ip" {
  description = "Public IPv4 of the first control-plane node, used to fetch the kubeconfig and bootstrap Flux."
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the OpenSSH private key OpenTofu uses to log into nodes after they boot."
  type        = string
}

variable "kubeconfig_output_path" {
  description = "Local filesystem path where the rewritten kubeconfig is written."
  type        = string
}

# ---- Flux bootstrap inputs --------------------------------------------------

variable "enable_flux_bootstrap" {
  description = "If true, run `flux bootstrap github` after the cluster is reachable."
  type        = bool
}

variable "github_owner" {
  description = "GitHub user or org that owns the Flux repository."
  type        = string
}

variable "github_repository" {
  description = "Flux repository name."
  type        = string
}

variable "github_branch" {
  description = "Flux repository branch."
  type        = string
}

variable "github_token" {
  description = "GitHub personal access token used by `flux bootstrap` (repo scope)."
  type        = string
  sensitive   = true
}

variable "flux_target_path" {
  description = "Path inside the GitHub repository where Flux writes its manifests."
  type        = string
}
