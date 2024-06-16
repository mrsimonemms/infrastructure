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

resource "hcloud_ssh_key" "server" {
  name       = format(local.name_format, "ssh-key")
  public_key = file(var.ssh_key_public)

  labels = merge(local.labels, {})
}

resource "hcloud_placement_group" "managers" {
  name = format(local.name_format, "k3s-managers")
  type = "spread"

  labels = merge(local.labels, {})
}

resource "hcloud_server" "manager" {
  count = var.k3s_manager_count

  name        = format(local.name_format, "manager-${count.index}")
  image       = var.k3s_manager_server_image
  server_type = var.k3s_manager_server_type
  location    = var.location
  ssh_keys = [
    hcloud_ssh_key.server.id
  ]
  placement_group_id = hcloud_placement_group.managers.id

  user_data = templatefile("${path.module}/files/k3s-manager.yaml", {
    sshPort   = var.ssh_port
    publicKey = hcloud_ssh_key.server.public_key
    user      = local.machine_user
  })

  network {
    network_id = hcloud_network.network.id
    # Set the alias_ips to avoid this triggering an update each run
    # @link https://github.com/hetznercloud/terraform-provider-hcloud/issues/650#issuecomment-1497160625
    alias_ips = []
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  labels = merge(local.k3s_manager_labels, {})

  depends_on = [
    hcloud_load_balancer_network.k3s_manager
  ]

  lifecycle {
    ignore_changes = [
      ssh_keys
    ]
  }
}
