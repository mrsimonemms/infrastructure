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

output "control_plane_public_ips" {
  description = "Public IPv4 addresses of the control-plane nodes, in node-index order."
  value       = [for n in var.control_plane_nodes : hcloud_server.control_plane[n.name].ipv4_address]
}

output "control_plane_private_ips" {
  description = "Private IPv4 addresses of the control-plane nodes, in node-index order."
  value       = [for n in var.control_plane_nodes : n.private_ip]
}

output "first_server_public_ip" {
  description = "Public IPv4 of the first control-plane node."
  value       = hcloud_server.control_plane[var.control_plane_nodes[0].name].ipv4_address
}

output "network_id" {
  description = "ID of the Hetzner private network."
  value       = hcloud_network.this.id
}

output "subnet_ip_range" {
  description = "CIDR of the control-plane subnet."
  value       = hcloud_network_subnet.control_plane.ip_range
}
