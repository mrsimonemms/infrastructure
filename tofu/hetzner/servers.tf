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

resource "hcloud_server" "control_plane" {
  for_each = { for n in var.control_plane_nodes : n.name => n }

  name        = each.key
  server_type = var.hetzner_server_type
  image       = var.hetzner_image
  location    = var.hetzner_location

  ssh_keys = [for k in hcloud_ssh_key.this : k.id]

  firewall_ids = [hcloud_firewall.control_plane.id]

  user_data = var.cloud_init_per_node[each.key]

  network {
    network_id = hcloud_network.this.id
    ip         = each.value.private_ip
  }

  labels = {
    cluster  = var.cluster_name
    role     = "control-plane"
    location = "cloud"
  }

  # The private network must exist before the server boots, otherwise
  # cloud-init will not see the private interface and k3s --node-ip will fail.
  depends_on = [
    hcloud_network_subnet.control_plane,
  ]
}
