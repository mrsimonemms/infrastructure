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

locals {
  global_ipv4_cidr = "0.0.0.0/0"
  global_ipv6_cidr = "::/0"
  k3s_manager_labels = merge(local.labels, {
    format(local.label_namespace, "type") = "manager"
  })
  k3s_worker_labels = merge(local.labels, {
    format(local.label_namespace, "type") = "worker"
  })
  # Convert pools into individual servers
  k3s_worker_pools = flatten([
    for w in var.k3s_worker_pools : [
      for n in range(w.count) :
      merge(
        w,
        {
          location = w.location != null ? w.location : var.location
          name     = "${w.name}-${n}"
          pool     = w.name
          labels = [
            {
              key   = "provider"
              value = "hetzner"
            }
          ]
        }
      )
    ]
  ])
  k3s_additional_pools = flatten([
    for poolName, nodes in var.k3s_existing_worker_pools : [
      for i, n in nodes : {
        name = lookup(n, "name", "${poolName}-${i}")
        pool = poolName
        labels = [
          {
            key   = "provider"
            value = "manual"
          }
        ]

        # Connection details
        host = n.host
        port = n.port
        user = n.user == null ? local.ssh_user : n.user
      }
    ]
  ])
  kubernetes_api_port = 6443
  labels = {
    format(local.label_namespace, "project")     = var.name
    format(local.label_namespace, "provisioner") = "terraform"
    format(local.label_namespace, "workspace")   = local.workspace_name
  }
  label_namespace = "simonemms.com/%s"
  name_format = join("-", [
    "hetzner",
    var.name,
    "%s", # resource name
    local.workspace_name
  ]) # use `format(local.name_format, "<name>")` to use this
  ssh_user = "k3smanager"
  user_data = templatefile("${path.module}/files/cloud-config.yaml", {
    sshPort   = var.ssh_port
    publicKey = hcloud_ssh_key.server.public_key
    user      = local.ssh_user
  })
  workspace_name = replace(var.workspace, "/[\\W]/", "") # alphanumeric workspace name
}
