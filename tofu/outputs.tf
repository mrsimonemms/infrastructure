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
  description = "Public IPv4 addresses of the Hetzner control-plane nodes, in node-index order."
  value       = module.hetzner.control_plane_public_ips
}

output "control_plane_private_ips" {
  description = "Private IPv4 addresses of the Hetzner control-plane nodes, in node-index order."
  value       = module.hetzner.control_plane_private_ips
}

output "first_server_public_ip" {
  description = "Public IPv4 of the first control-plane node (use this as the kubeconfig server endpoint)."
  value       = module.hetzner.first_server_public_ip
}

output "kubeconfig_path" {
  description = "Local filesystem path to the kubeconfig fetched after cluster bootstrap."
  value       = module.bootstrap.kubeconfig_path
}

output "k3s_join_command" {
  description = "One-liner for joining a future Raspberry Pi worker. Run on the Pi as root after replacing FIRST_NODE_IP and TOKEN placeholders if needed."
  value       = module.bootstrap.k3s_join_command
  sensitive   = true
}
