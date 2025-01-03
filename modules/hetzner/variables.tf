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

variable "firewall_allow_api_access" {
  type        = list(string)
  description = "CIDR range to allow access to the Kubernetes API"
  default = [
    "0.0.0.0/0",
    "::/0"
  ]
}

variable "firewall_allow_ssh_access" {
  type        = list(string)
  description = "CIDR range to allow access to the servers via SSH"
  default = [
    "0.0.0.0/0",
    "::/0"
  ]
}

variable "k3s_manager_load_balancer_algorithm" {
  type        = string
  description = "Algorithm to use for the k3s manager load balancer"
  default     = "round_robin"
}

variable "k3s_manager_load_balancer_type" {
  type        = string
  description = "Load balancer type for the k3s manager nodes"
  default     = "lb11"
}

variable "k3s_manager_pool" {
  type = object({
    name        = optional(string, "manager")
    server_type = optional(string, "cx22")
    count       = optional(number, 1)
    image       = optional(string, "ubuntu-24.04")
  })
  description = "Manager pool configuration"
  default     = {}

  validation {
    condition     = var.k3s_manager_pool.count >= 1 && var.k3s_manager_pool.count % 2 == 1
    error_message = "Invalid k3s_manager_pool.count given."
  }
}

variable "k3s_worker_pools" {
  type = list(object({
    name        = string
    server_type = optional(string, "cx22")
    count       = optional(number, 1)
    image       = optional(string, "ubuntu-24.04")
    location    = optional(string) # Defaults to var.location if not set
  }))
  description = "Worker pools configuration"
  default     = []
}

variable "kubeconfig_output_path" {
  type        = string
  description = "Output path for the Kubeconfig"
  default     = "~/.kube/config"
}

variable "location" {
  type        = string
  description = "Location to use. This is a single datacentre."
  default     = "nbg1"
}

variable "name" {
  type        = string
  description = "Name of project"
  default     = "k3s"
}

variable "network_type" {
  type        = string
  description = "Type of network to use"
  default     = "cloud"

  validation {
    condition     = contains(["cloud", "server", "vswitch"], var.network_type)
    error_message = "Invalid network_type selected."
  }
}

variable "network_subnet" {
  type        = string
  description = "Subnet of the main network"
  default     = "10.0.0.0/16"
}

variable "region" {
  type        = string
  description = "Region to use. This covers multiple datacentres."
  default     = "eu-central"
}

variable "ssh_key" {
  sensitive   = true
  type        = string
  description = "Private SSH key"
}

variable "ssh_key_public" {
  type        = string
  description = "Public SSH key"
}

variable "ssh_port" {
  type        = number
  description = "Port to use for SSH access"
  default     = 2244
}

variable "workspace" {
  type        = string
  description = "Terraform workspace name"
  default     = "default"
}
