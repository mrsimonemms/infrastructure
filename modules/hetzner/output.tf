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

output "kubeconfig" {
  sensitive   = true
  description = "Kubeconfig"
  value       = module.k3s.kubeconfig
}

output "kube_api_server" {
  sensitive   = true
  description = "Kubernetes API server address"
  value       = module.k3s.kube_api_server
}

output "k3s_cluster_cidr" {
  description = "CIDR used for the k3s cluster"
  value       = module.k3s.cluster_cidr
}

output "location" {
  description = "Location to use. This is a single datacentre."
  value       = var.location
}

output "network_name" {
  description = "Name of the network"
  value       = hcloud_network.network.name
}

output "pools" {
  sensitive   = true
  description = "Servers created"
  value = merge(
    {
      managers : [
        for m in hcloud_server.manager : {
          name         = m.name
          ipv4_address = m.ipv4_address
          ipv6_address = m.ipv6_address
        }
      ]
    },
    {
      for k, w in local.k3s_worker_pools : w.pool => {
        name         = hcloud_server.workers[k].name
        ipv4_address = hcloud_server.workers[k].ipv4_address
        ipv6_address = hcloud_server.workers[k].ipv6_address
      }...
    }
  )
}

output "region" {
  description = "Region to use. This covers multiple datacentres."
  value       = var.region
}

output "ssh_port" {
  description = "SSH port for server"
  value       = var.ssh_port
}

output "ssh_user" {
  description = "SSH user for server"
  value       = local.ssh_user
}
