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

resource "hcloud_network" "network" {
  name     = format(local.name_format, "network")
  ip_range = var.network_subnet

  labels = merge(local.labels, {})
}

resource "hcloud_network_subnet" "subnet" {
  network_id   = hcloud_network.network.id
  type         = var.network_type
  network_zone = var.region
  ip_range     = var.network_subnet
}

resource "hcloud_firewall" "name" {
  name = format(local.name_format, "firewall")

  dynamic "rule" {
    for_each = [
      {
        description = "SSH port"
        port        = var.ssh_port
        source_ips  = var.firewall_allow_ssh_access
      },
      {
        description = "ICMP"
        port        = null
        protocol    = "icmp"
        source_ips = [
          local.global_ipv4_cidr,
          local.global_ipv6_cidr,
        ]
      },
      {
        description = "Allow all TCP traffic on private network"
        source_ips = [
          hcloud_network.network.ip_range
        ]
      },
      {
        description = "Allow all UDP traffic on private network"
        source_ips = [
          hcloud_network.network.ip_range
        ]
      },
      {
        description = "Allow access to Kubernetes API"
        port        = local.kubernetes_api_port
        source_ips  = var.firewall_allow_api_access
      }
    ]
    content {
      description     = lookup(rule.value, "description", "")
      destination_ips = lookup(rule.value, "destination_ips", [])
      direction       = lookup(rule.value, "direction", "in")
      port            = lookup(rule.value, "port", "any")
      protocol        = lookup(rule.value, "protocol", "tcp")
      source_ips      = lookup(rule.value, "source_ips", [])
    }
  }

  apply_to {
    label_selector = join(",", [for key, value in local.labels : "${key}=${value}"])
  }

  labels = merge(local.labels, {})
}
