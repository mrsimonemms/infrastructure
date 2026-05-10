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

resource "random_password" "k3s_token" {
  length  = 64
  special = false
}

# Per-cluster SSH key used by OpenTofu (and any local provisioners) to reach
# nodes after they boot. The user-supplied keys in var.ssh_public_keys are
# also installed - this one is just so OpenTofu can fetch the kubeconfig
# without depending on the operator's personal key being available.
resource "tls_private_key" "ssh" {
  algorithm = "ED25519"
}

resource "local_sensitive_file" "ssh_private_key" {
  filename        = "${path.module}/.ssh/id_ed25519"
  content         = tls_private_key.ssh.private_key_openssh
  file_permission = "0600"
}

locals {
  control_plane_nodes = [
    for i in range(var.node_count) : {
      index         = i
      name          = format("%s-cp-%d", var.cluster_name, i + 1)
      private_ip    = cidrhost(var.subnet_cidr, var.control_plane_ip_offset + i)
      is_first_node = i == 0
    }
  ]

  first_node_private_ip = local.control_plane_nodes[0].private_ip

  ssh_public_keys = concat(
    var.ssh_public_keys,
    [trimspace(tls_private_key.ssh.public_key_openssh)],
  )
}

module "hetzner" {
  source = "./hetzner"

  cluster_name           = var.cluster_name
  hetzner_location       = var.hetzner_location
  hetzner_server_type    = var.hetzner_server_type
  hetzner_image          = var.hetzner_image
  network_cidr           = var.network_cidr
  subnet_cidr            = var.subnet_cidr
  control_plane_nodes    = local.control_plane_nodes
  cloud_init_per_node    = module.bootstrap.cloud_init_per_node
  ssh_public_keys        = local.ssh_public_keys
  allowed_ssh_cidrs      = var.allowed_ssh_cidrs
  allowed_kube_api_cidrs = var.allowed_kube_api_cidrs
}

module "bootstrap" {
  source = "./bootstrap"

  cluster_name           = var.cluster_name
  control_plane_nodes    = local.control_plane_nodes
  first_node_private_ip  = local.first_node_private_ip
  k3s_token              = random_password.k3s_token.result
  k3s_version            = var.k3s_version
  k3s_tls_sans           = var.k3s_tls_sans
  cloud_node_labels      = var.cloud_node_labels
  ssh_authorized_keys    = local.ssh_public_keys
  ssh_private_key_path   = local_sensitive_file.ssh_private_key.filename
  first_server_public_ip = module.hetzner.first_server_public_ip
  kubeconfig_output_path = var.kubeconfig_output_path

  enable_flux_bootstrap = var.enable_flux_bootstrap
  github_owner          = var.github_owner
  github_repository     = var.github_repository
  github_branch         = var.github_branch
  github_token          = var.github_token
  flux_target_path      = var.flux_target_path
}
