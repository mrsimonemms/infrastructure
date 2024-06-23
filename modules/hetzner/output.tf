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

output "hcloud_network_name" {
  description = "Name of the network"
  value       = hcloud_network.network.name
}

output "k3s_cluster_cidr" {
  description = "CIDR used for the k3s cluster"
  value       = var.k3s_cluster_cidr
}

output "k3s_join_token" {
  description = "K3s join token for adding additional nodes"
  sensitive   = true
  value       = local.k3s_join_token
}

output "kubeconfig" {
  description = "Kubeconfig file"
  sensitive   = true
  value       = local.k3s_kubeconfig
}

output "location" {
  description = "Location to use. This is a single datacentre."
  value       = var.location
}

output "region" {
  description = "Region to use. This covers multiple datacentres."
  value       = var.region
}
