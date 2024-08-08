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
  drain_timeout  = "60s"
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
          "--disable metrics-storage",
          "--disable servicelb",
          "--disable traefik",
          "--disable-cloud-controller",
          "--disable-network-policy",
          "--flannel-backend wireguard-native",
          "--kube-controller-manager-arg bind-address=0.0.0.0",
          "--kube-proxy-arg metrics-bind-address=0.0.0.0",
          "--kube-scheduler-arg bind-address=0.0.0.0",
          "--write-kubeconfig-mode 0644",
        ],
        [for i in hcloud_server.manager : "--tls-san ${i.ipv4_address}"],          # Server's public address
        [for i in hcloud_server.manager : "--tls-san ${tolist(i.network)[0].ip}"], # Server's private address
        # Load balancer, if created
        var.k3s_manager_pool.count > 1 ? ["--tls-san ${hcloud_load_balancer.k3s_manager[0].ipv4}"] : []
      )

      annotations = { "server_id" : i } # these annotations will not be managed by this module
    }
  }

  agents = {
    for i in range(length(hcloud_server.workers)) : hcloud_server.workers[i].name => {
      ip = tolist(hcloud_server.workers[i].network)[0].ip
      connection = {
        host        = hcloud_server.manager[i].ipv4_address
        user        = local.ssh_user
        private_key = file(var.ssh_key)
        port        = var.ssh_port
      }

      labels = {
        "node.kubernetes.io/pool" = local.k3s_worker_pools[0].pool
      }
    }
  }

  depends_on = [
    ssh_resource.manager_ready,
    ssh_resource.workers_ready,
  ]
}

resource "ssh_resource" "install_ccm" {
  host        = hcloud_server.manager[0].ipv4_address
  user        = local.ssh_user
  private_key = file(var.ssh_key)
  port        = var.ssh_port

  timeout     = "1m"
  retry_delay = "5s"

  commands = [
    "kubectl -n kube-system create secret generic hcloud --from-literal=network=${hcloud_network.network.name} --from-literal=token=${var.hcloud_token} --dry-run=client -o yaml | kubectl replace --force -f -",
    "kubectl apply -f ${var.hcloud_ccm_file}",
    "kubectl rollout restart -n kube-system deployment hcloud-cloud-controller-manager"
  ]

  triggers = {
    always = timestamp()
  }

  depends_on = [module.k3s]
}
