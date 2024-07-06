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
  k3s_access_address = var.k3s_manager_pool.count > 1 ? hcloud_load_balancer.k3s_manager[0].ipv4 : local.k3s_initial_manager.ipv4_address
  k3s_common_manager_config = {
    cluster-cidr = var.k3s_cluster_cidr
    cluster-dns  = var.k3s_cluster_dns
    cluster-init = var.k3s_manager_pool.count > 1
    disable = [
      "local-storage",
      "metrics-server",
      "servicelb",
      "traefik"
    ]
    disable-cloud-controller = true
    disable-network-policy   = true
    flannel-backend          = "wireguard-native"
    kubelet-arg = [
      "cloud-provider=external"
    ]
    kube-controller-manager-arg = "bind-address=0.0.0.0"
    kube-proxy-arg              = "metrics-bind-address=0.0.0.0"
    kube-scheduler-arg          = "bind-address=0.0.0.0"
    node-label                  = [for l in var.k3s_manager_pool.labels : "${l.key}=${l.value}"]
    node-taint = [for t in concat(
      var.schedule_workloads_on_manager_nodes ? [] : [
        {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NoExecute"
        }
      ],
      var.k3s_manager_pool.taints
    ) : "${t.key}=${t.value}:${t.effect}"]
    service-cidr = var.k3s_service_cidr
    tls-san = concat(
      [local.k3s_access_address],
      [for o in hcloud_server.manager : tolist(o.network)[0].ip]
    )
    write-kubeconfig-mode = "0644"
  }
  k3s_common_worker_config = {
    kubelet-arg = [
      "cloud-provider=external"
    ]
    server = local.k3s_server_url
    token  = local.k3s_join_token
  }
  k3s_install_command = [
    # Get the network interface
    "ip route get ${cidrhost(var.network_subnet, 0)} | awk -F \"dev \" 'NR==1{split($2,a,\" \");print a[1]}' > /tmp/network-interface",
    "yq -y -i \".[\\\"flannel-iface\\\"] = \\\"$(cat /tmp/network-interface)\\\"\" /tmp/k3sconfig.yaml",
    # Copy the config file
    "sudo mkdir -p /etc/rancher/k3s",
    "sudo mv /tmp/k3sconfig.yaml /etc/rancher/k3s/config.yaml",
    # Install k3s
    format(
      "curl -sfL %s | sh -",
      var.k3s_download_url,
    ),
    # Ensure k3s is running
    "sudo systemctl start k3s"
  ]
  k3s_initial_manager            = hcloud_server.manager[0]
  k3s_initial_manager_private_ip = tolist(local.k3s_initial_manager.network)[0].ip
  k3s_join_token                 = chomp(ssh_sensitive_resource.join_token.result)
  k3s_kubeconfig                 = chomp(ssh_sensitive_resource.kubeconfig.result)
  k3s_server_url                 = "https://${var.k3s_manager_pool.count > 1 ? hcloud_load_balancer.k3s_manager[0].ipv4 : local.k3s_initial_manager_private_ip}:${local.kubernetes_api_port}"
}

resource "ssh_resource" "initial_manager" {
  host        = local.k3s_initial_manager.ipv4_address
  user        = local.machine_user
  private_key = file(var.ssh_key)
  port        = var.ssh_port

  commands = local.k3s_install_command

  file {
    content = yamlencode(merge(local.k3s_common_manager_config, {
      advertise-address = local.k3s_initial_manager_private_ip # Private IP
      node-name         = local.k3s_initial_manager.name
      node-external-ip  = local.k3s_initial_manager.ipv4_address # Public IP
      node-ip           = local.k3s_initial_manager_private_ip   # Private IP
    }))
    destination = "/tmp/k3sconfig.yaml"
  }

  timeout     = "5m"
  retry_delay = "5s"

  depends_on = [
    ssh_resource.server_ready
  ]

  triggers = {
    server_id = local.k3s_initial_manager.id
  }
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

  triggers = {
    server_id = local.k3s_initial_manager.id
  }
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

  triggers = {
    server_id = local.k3s_initial_manager.id
  }
}

resource "ssh_sensitive_resource" "additional_managers" {
  count = var.k3s_manager_pool.count - 1

  host        = hcloud_server.manager[count.index + 1].ipv4_address
  user        = local.machine_user
  private_key = file(var.ssh_key)
  port        = var.ssh_port

  commands = local.k3s_install_command

  file {
    content = yamlencode(merge(local.k3s_common_manager_config, {
      advertise-address = tolist(hcloud_server.manager[count.index + 1].network)[0].ip # Private IP
      node-name         = hcloud_server.manager[count.index + 1].name
      node-external-ip  = hcloud_server.manager[count.index + 1].ipv4_address          # Public IP
      node-ip           = tolist(hcloud_server.manager[count.index + 1].network)[0].ip # Private IP
      server            = local.k3s_server_url
      token             = local.k3s_join_token
    }))
    destination = "/tmp/k3sconfig.yaml"
  }

  timeout     = "5m"
  retry_delay = "5s"

  depends_on = [
    ssh_resource.initial_manager
  ]

  triggers = {
    server_id = hcloud_server.manager[count.index + 1].id
  }
}
