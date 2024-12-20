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


# Only use managers as ingress IP
data "hcloud_servers" "manager_nodes" {
  with_selector = "cluster=${var.cluster_name},role=master"
}

resource "kubernetes_namespace_v1" "metallb" {
  metadata {
    name = "metallb-system"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
    ]
  }
}

resource "kubernetes_config_map_v1" "metallb" {
  metadata {
    name      = "nodes"
    namespace = kubernetes_namespace_v1.metallb.metadata[0].name
  }

  data = {
    resource = yamlencode({
      apiVersion = "metallb.io/v1beta1"
      kind       = "IPAddressPool"
      metadata = {
        name      = "nodes"
        namespace = kubernetes_namespace_v1.metallb.metadata[0].name
      }
      spec = {
        addresses = [for s in data.hcloud_servers.manager_nodes.servers : s.ipv4_address]
      }
    })
  }

  immutable = false
}
