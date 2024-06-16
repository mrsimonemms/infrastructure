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
  k3s_access_address             = var.k3s_manager_count > 1 ? hcloud_load_balancer.k3s_manager[0].ipv4 : local.k3s_initial_manager.ipv4_address
  k3s_initial_manager            = hcloud_server.manager[0]
  k3s_initial_manager_private_ip = tolist(local.k3s_initial_manager.network)[0].ip
  k3s_join_token                 = chomp(ssh_sensitive_resource.join_token.result)
  k3s_kubeconfig                 = chomp(ssh_sensitive_resource.kubeconfig.result)
  k3s_manager_install_command = join(" ", concat(
    [
      "server",
      "--write-kubeconfig-mode=0644",
      "--disable servicelb",
      "--disable traefik",
      "--node-name=$(hostname -f)",
      "--node-external-ip=$(hostname -I | awk '{print $1}')",  # Public IP
      "--node-ip=$(hostname -I | awk '{print $2}')",           # Private IP
      "--advertise-address=$(hostname -I | awk '{print $2}')", # Private IP
    ],
    # Set TLS SANs - first, add load balancer or managers's public address
    var.k3s_manager_count > 1 ? [
      "--cluster-init",
      "--tls-san=${hcloud_load_balancer.k3s_manager[0].ipv4}"
      ] : [
      "--tls-san=${local.k3s_access_address}"
    ],
    # Now, add all the servers
    [for o in hcloud_server.manager : "--tls-san=${tolist(o.network)[0].ip}"]
  ))
}

resource "ssh_resource" "server_ready" {
  count = var.k3s_manager_count

  host        = hcloud_server.manager[count.index].ipv4_address
  user        = local.machine_user
  private_key = file(var.ssh_key)
  port        = var.ssh_port

  timeout     = "5m"
  retry_delay = "5s"

  commands = [
    "cloud-init status | grep \"status: done\""
  ]

  depends_on = [
    hcloud_server.manager
  ]
}

resource "ssh_resource" "initial_manager" {
  host        = local.k3s_initial_manager.ipv4_address
  user        = local.machine_user
  private_key = file(var.ssh_key)
  port        = var.ssh_port

  commands = [
    format(
      "curl -sfL %s | INSTALL_K3S_EXEC=\"%s\" %s sh -",
      var.k3s_download_url,
      // Install configuration
      local.k3s_manager_install_command,
      // Other k3s configuration
      ""
    ),
    # Ensure k3s is running
    "sudo systemctl start k3s"
  ]

  timeout     = "5m"
  retry_delay = "5s"

  depends_on = [
    ssh_resource.server_ready
  ]
}

resource "ssh_sensitive_resource" "join_token" {
  host        = local.k3s_initial_manager.ipv4_address
  user        = local.machine_user
  private_key = file(var.ssh_key)
  port        = var.ssh_port

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
  port        = var.ssh_port

  commands = [
    format("sudo cat /etc/rancher/k3s/k3s.yaml | sed 's/%s/%s/'", "127.0.0.1", local.k3s_access_address)
  ]

  timeout     = "5m"
  retry_delay = "5s"

  depends_on = [
    ssh_resource.initial_manager
  ]
}

resource "ssh_sensitive_resource" "additional_managers" {
  count = var.k3s_manager_count - 1

  host        = hcloud_server.manager[count.index + 1].ipv4_address
  user        = local.machine_user
  private_key = file(var.ssh_key)
  port        = var.ssh_port

  commands = [
    format(
      "curl -sfL %s | INSTALL_K3S_EXEC=\"%s\" %s sh -",
      var.k3s_download_url,
      // Install configuration
      local.k3s_manager_install_command,
      // Other k3s configuration
      join(" ", [
        "K3S_URL=https://${local.k3s_initial_manager_private_ip}:6443",
        "K3S_TOKEN=${local.k3s_join_token}"
      ])
    ),
    # Ensure k3s is running
    "sudo systemctl start k3s"
  ]

  timeout     = "5m"
  retry_delay = "5s"

  depends_on = [
    ssh_resource.initial_manager
  ]
}
