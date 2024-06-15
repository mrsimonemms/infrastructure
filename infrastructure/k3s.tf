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
  k3s_initial_manager            = hcloud_server.manager[0]
  k3s_initial_manager_private_ip = tolist(local.k3s_initial_manager.network)[0].ip
  k3s_tls_san                    = var.k3s_manager_count > 1 ? hcloud_load_balancer.k3s_manager[0].ipv4 : local.k3s_initial_manager.ipv4_address
  k3s_join_token                 = chomp(ssh_sensitive_resource.join_token.result)
  k3s_kubeconfig                 = chomp(ssh_sensitive_resource.kubeconfig.result)
}

resource "ssh_resource" "server_ready" {
  count = var.k3s_manager_count

  host        = hcloud_server.manager[count.index].ipv4_address
  user        = local.machine_user
  private_key = file(var.ssh_key)

  timeout     = "5m"
  retry_delay = "5s"

  commands = [
    "cloud-init status | grep \"status: done\""
  ]

  triggers = {
    always_run = timestamp()
  }

  depends_on = [
    hcloud_server.manager
  ]
}

resource "ssh_resource" "initial_manager" {
  host        = local.k3s_initial_manager.ipv4_address
  user        = local.machine_user
  private_key = file(var.ssh_key)

  commands = [
    format(
      "curl -sfL %s | INSTALL_K3S_EXEC=\"%s\" %s sh -",
      var.k3s_download_url,
      // Install configuration
      join(" ", [
        "server",
        "--write-kubeconfig-mode=0644",
        "--disable servicelb",
        "--disable traefik",
        "--tls-san=${local.k3s_tls_san}",
        "--node-name=$(hostname -f)",
        "--node-external-ip=$(hostname -I | awk '{print $1}')",  # Public IP
        "--node-ip=$(hostname -I | awk '{print $2}')",           # Private IP
        "--advertise-address=$(hostname -I | awk '{print $2}')", # Private IP
      ]),
      // Other k3s configuration
      ""
    )
  ]

  timeout     = "5m"
  retry_delay = "5s"


  triggers = {
    always_run = timestamp()
  }

  depends_on = [
    ssh_resource.server_ready
  ]
}

resource "ssh_sensitive_resource" "join_token" {
  host        = local.k3s_initial_manager.ipv4_address
  user        = local.machine_user
  private_key = file(var.ssh_key)

  commands = [
    "sudo cat /var/lib/rancher/k3s/server/token"
  ]

  timeout     = "5m"
  retry_delay = "5s"

  depends_on = [
    ssh_resource.initial_manager
  ]
}

resource "ssh_sensitive_resource" "kubeconfig" {
  host        = local.k3s_initial_manager.ipv4_address
  user        = local.machine_user
  private_key = file(var.ssh_key)

  commands = [
    format("sudo cat /etc/rancher/k3s/k3s.yaml | sed 's/%s/%s/'", "127.0.0.1", local.k3s_tls_san)
  ]

  timeout     = "5m"
  retry_delay = "5s"

  depends_on = [
    ssh_resource.initial_manager
  ]
}
