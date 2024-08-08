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

module "k3s" {
  source  = "xunleii/k3s/module"
  version = ">= 3.4.0, < 4.0.0"

  cluster_domain = format(local.name_format, "cluster")
  k3s_version    = "latest"
  use_sudo       = false
  cidr = {
    pods     = "10.42.0.0/16"
    services = "10.43.0.0/16"
  }
  drain_timeout  = "30s"
  managed_fields = ["label", "taint"] # ignore annotations

  global_flags = [
    "--flannel-iface eth0",
    "--kubelet-arg cloud-provider=external" # required to use https://github.com/hetznercloud/hcloud-cloud-controller-manager
  ]

  servers = {
    for i in range(length(hcloud_server.manager)) : hcloud_server.manager[i].name => {
      ip = tolist(hcloud_server.manager[i].network)[0].ip
      connection = {
        host        = hcloud_server.manager[i].ipv4_address
        user        = local.ssh_user
        private_key = file(var.ssh_key)
        port        = var.ssh_port
      }

      flags = concat(
        [
          "--disable-cloud-controller",
          "--write-kubeconfig-mode 0644",
        ],
        [for i in hcloud_server.manager : "--tls-san ${i.ipv4_address}"],          # Server's public address
        [for i in hcloud_server.manager : "--tls-san ${tolist(i.network)[0].ip}"], # Server's private address
        # Load balancer, if created
        var.k3s_manager_pool.count > 1 ? [
          "--tls-san ${hcloud_load_balancer.k3s_manager[0].ipv4}",      # Public IP
          "--tls-san ${hcloud_load_balancer.k3s_manager[0].network_ip}" # Private IP
        ] : []
      )

      annotations = { "server_id" : i } # these annotations will not be managed by this module
    }
  }

  agents = {}

  depends_on = [
    ssh_resource.manager_ready,
    ssh_resource.workers_ready,
  ]
}
