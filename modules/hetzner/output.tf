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

# output "worker_placement_groups" {
#   description = "Placement groups of worker node pools"
#   value       = local.worker_placement_groups
# }

output "worker_pools" {
  sensitive   = true
  description = "Worker pool configuration for Cluster Autoscaler"
  value = {
    firewall_id = hcloud_firewall.name.id
    network_id  = hcloud_network.network.id
    ssh_key_id  = hcloud_ssh_key.server.id
    pools = [for w in var.k3s_worker_pools : {
      min         = w.autoscaling.enabled ? w.autoscaling.min : w.count
      max         = w.autoscaling.enabled ? w.autoscaling.max : w.count
      server_type = w.server_type
      location    = w.location != null ? w.location : var.location
      name        = w.name
    }]
    config = {
      imagesForArch = {
        arm64 = "ubuntu-24.04"
        amd64 = "ubuntu-24.04"
      }
      nodeConfigs = { for w in var.k3s_worker_pools :
        w.name => {
          cloudInit = templatefile("${path.module}/files/k3s-worker.yaml", {
            k3s_config = {
              node-name = format(local.name_format, w.name)
              server    = local.k3s_server_url
              token     = local.k3s_join_token
            }
            k3s_download_url = var.k3s_download_url
            sshPort          = var.ssh_port
            publicKey        = hcloud_ssh_key.server.public_key
            user             = local.machine_user
          })
          labels = concat(
            // Add the pool name as a label
            [
              {
                key   = "node.kubernetes.io/role"
                value = "autoscaler-node"
              },
              {
                key   = format(local.label_namespace, "pool"),
                value = w.name
              },
            ],
            w.labels,
          )
          taints = concat([
            {
              key    = "node.kubernetes.io/role",
              value  = "autoscaler-node",
              effect = "NoExecute"
            }
            ],
            w.taints,
          )
        }
      }
    }
  }
}
