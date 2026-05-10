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

output "cloud_init_per_node" {
  description = "Map of node-name -> rendered cloud-init YAML, consumed by module.hetzner as user_data."
  value       = local.cloud_init_per_node
  # Contains the k3s join token. Hetzner cloud-init lives on the server, so
  # this is not "more" sensitive than the deployed VM, but mark it sensitive
  # so it does not leak into plan output.
  sensitive = true
}

output "kubeconfig_path" {
  description = "Local filesystem path of the rewritten kubeconfig."
  value       = var.kubeconfig_output_path
}

output "k3s_join_command" {
  description = "Shell snippet for joining a future Pi worker. Replace the public IP and run on the Pi."
  value = join(" \\\n", [
    "K3S_URL=\"https://${var.first_server_public_ip}:6443\"",
    "K3S_TOKEN=\"${var.k3s_token}\"",
    "INSTALL_K3S_EXEC=\"agent --node-label topology.simonemms.com/location=home --node-label node-role.simonemms.com/worker=true\"",
    "curl -sfL https://get.k3s.io | sh -",
  ])
  sensitive = true
}
