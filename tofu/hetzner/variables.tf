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

variable "cluster_name" {
  description = "Logical cluster name, used as a prefix for Hetzner resource names and labels."
  type        = string
}

variable "hetzner_location" {
  description = "Hetzner location for the control-plane nodes (nbg1, fsn1, hel1, ...)."
  type        = string
}

variable "hetzner_server_type" {
  description = "Hetzner server type for the control-plane nodes."
  type        = string
}

variable "hetzner_image" {
  description = "Hetzner OS image for the control-plane nodes."
  type        = string
}

variable "network_cidr" {
  description = "CIDR for the Hetzner private network."
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR for the control-plane subnet inside network_cidr."
  type        = string
}

variable "control_plane_nodes" {
  description = "Per-node descriptors (index, name, private_ip, is_first_node) computed by the root module."
  type = list(object({
    index         = number
    name          = string
    private_ip    = string
    is_first_node = bool
  }))
}

variable "cloud_init_per_node" {
  description = "Map of node-name -> rendered cloud-init YAML (sourced from the bootstrap module)."
  type        = map(string)
}

variable "ssh_public_keys" {
  description = "OpenSSH public keys to register with Hetzner and install on each node."
  type        = list(string)
}

variable "allowed_ssh_cidrs" {
  description = "CIDRs permitted to reach SSH on the public interface."
  type        = list(string)
}

variable "allowed_kube_api_cidrs" {
  description = "CIDRs permitted to reach the Kubernetes API on the public interface."
  type        = list(string)
}
