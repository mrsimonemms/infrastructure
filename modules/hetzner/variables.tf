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

# variable "location" {
#   type        = string
#   description = "Location to use. This is a single datacentre."
#   default     = "nbg1"
# }

variable "name" {
  type        = string
  description = "Name of project"
  default     = "infrastructure"
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

variable "ssh_port" {
  type        = number
  description = "Port to use for SSH access"
  default     = 22
}

variable "workspace" {
  type        = string
  description = "Terraform workspace name"
  default     = "default"
}
