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

##########
# Common #
##########
resource "hcloud_ssh_key" "server" {
  name       = format(local.name_format, "ssh_key")
  public_key = file(var.ssh_key_public)

  labels = merge(local.k3s_manager_labels, {})
}

############
# Managers #
############
resource "hcloud_placement_group" "managers" {
  count = var.k3s_manager_pool.count > 1 ? 1 : 0

  name = format(local.name_format, "manager")
  type = "spread"

  labels = merge(local.k3s_manager_labels, {})
}

resource "hcloud_server" "manager" {
  count = var.k3s_manager_pool.count

  name        = format(local.name_format, "manager-${count.index}")
  image       = var.k3s_manager_pool.image
  server_type = var.k3s_manager_pool.server_type
  location    = var.location
  ssh_keys = [
    hcloud_ssh_key.server.id
  ]

  # No placement group if single node manager
  placement_group_id = try(hcloud_placement_group.managers[0].id, null)

  user_data = local.user_data

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

##################
# Static workers #
##################
resource "hcloud_placement_group" "workers" {
  for_each = toset([for i in var.k3s_worker_pools : i.name])

  name = format(local.name_format, each.value)
  type = "spread"

  labels = merge(local.k3s_worker_labels, {})
}

resource "hcloud_server" "workers" {
  for_each = { for i in local.k3s_worker_pools : i.name => i }

  name        = format(local.name_format, each.value.name)
  image       = each.value.image
  server_type = each.value.server_type
  location    = each.value.location
  ssh_keys = [
    hcloud_ssh_key.server.id
  ]
  placement_group_id = hcloud_placement_group.workers[each.value.pool].id

  user_data = local.user_data

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

  labels = merge(local.k3s_worker_labels, {
    format(local.label_namespace, "pool") = each.value.pool
  })

  lifecycle {
    ignore_changes = [
      ssh_keys
    ]
  }
}
