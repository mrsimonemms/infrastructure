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

output "worker_pools" {
  sensitive   = true
  description = "Worker pool configuration for Cluster Autoscaler"
  value = [
    for w in var.k3s_worker_pools : {
      labels = concat([
        {
          key   = "node.kubernetes.io/role"
          value = "autoscaler-node"
        },
        {
          key   = format(local.label_namespace, "pool")
          value = w.name
        },
        ],
        w.labels,
      )
      taints = w.taints
      cloud_init = templatefile("${path.module}/files/k3s-worker.yaml", {
        k3s_config = merge(local.k3s_common_worker_config, {
          node-label = [for l in concat(
            [
              {
                key   = "node.kubernetes.io/role"
                value = "autoscaler-node"
              },
              {
                key   = format(local.label_namespace, "pool")
                value = w.name
              },
            ],
            w.labels,
          ) : "${l.key}=${l.value}"]
          node-taint = [for t in w.taints : "${t.key}=${t.value}:${t.effect}"]
        })
        k3s_download_url = var.k3s_download_url
        sshPort          = var.ssh_port
        publicKey        = hcloud_ssh_key.server.public_key
        user             = local.machine_user
      })
      firewall_id = hcloud_firewall.name.id
      image       = w.image,
      network_id  = hcloud_network.network.id
      pool = {
        instanceType = w.server_type
        minSize      = w.autoscaling.min
        maxSize      = w.autoscaling.max
        name         = w.name
        region       = w.location != null ? w.location : var.location
      }
      ssh_key_id = hcloud_ssh_key.server.id
    } if lookup(w.autoscaling, "enabled", false) == true
  ]
}
