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

# ---- cloud-init rendering ---------------------------------------------------
# Per-node cloud-init is computed from inputs that are known up front (cluster
# config, node descriptors, k3s token). It deliberately does not reference
# var.first_server_public_ip - that variable feeds the post-cluster resources
# below, and mixing the two would cycle through module.hetzner.

locals {
  cloud_init_per_node = {
    for n in var.control_plane_nodes : n.name => templatefile("${path.module}/cloud-init.yaml.tftpl", {
      hostname              = n.name
      is_first_node         = n.is_first_node
      first_node_private_ip = var.first_node_private_ip
      node_private_ip       = n.private_ip
      k3s_token             = var.k3s_token
      k3s_version           = var.k3s_version
      node_labels           = var.cloud_node_labels
      tls_sans              = var.k3s_tls_sans
      ssh_authorized_keys   = var.ssh_authorized_keys
    })
  }

  # Common SSH options for the local-exec provisioners. ed25519 host keys are
  # generated fresh on each VM, so StrictHostKeyChecking would fail.
  ssh_opts = "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o ConnectTimeout=10"
}

# ---- wait for the API to come up -------------------------------------------

resource "terraform_data" "wait_for_k3s" {
  triggers_replace = {
    first_server_public_ip = var.first_server_public_ip
  }

  provisioner "local-exec" {
    interpreter = ["/usr/bin/env", "bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      attempts=0
      until ssh -i "${var.ssh_private_key_path}" ${local.ssh_opts} \
            root@${var.first_server_public_ip} \
            'k3s kubectl get nodes -o name 2>/dev/null | wc -l | grep -q ^${length(var.control_plane_nodes)}$' \
            >/dev/null 2>&1; do
        attempts=$((attempts + 1))
        if [ "$attempts" -gt 60 ]; then
          echo "k3s did not become ready within 10 minutes" >&2
          exit 1
        fi
        echo "[wait-for-k3s] cluster not ready yet (attempt $attempts)..."
        sleep 10
      done
      echo "[wait-for-k3s] all ${length(var.control_plane_nodes)} nodes registered"
    EOT
  }
}

# ---- fetch and rewrite kubeconfig ------------------------------------------

resource "terraform_data" "fetch_kubeconfig" {
  triggers_replace = {
    cluster_ready = terraform_data.wait_for_k3s.id
    target_path   = var.kubeconfig_output_path
  }

  provisioner "local-exec" {
    interpreter = ["/usr/bin/env", "bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      mkdir -p "$(dirname '${var.kubeconfig_output_path}')"
      ssh -i "${var.ssh_private_key_path}" ${local.ssh_opts} \
        root@${var.first_server_public_ip} \
        'cat /etc/rancher/k3s/k3s.yaml' \
        | sed "s|server: https://127.0.0.1:6443|server: https://${var.first_server_public_ip}:6443|" \
        > '${var.kubeconfig_output_path}'
      chmod 0600 '${var.kubeconfig_output_path}'
      echo "[fetch-kubeconfig] wrote ${var.kubeconfig_output_path}"
    EOT
  }
}
