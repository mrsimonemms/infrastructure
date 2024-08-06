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
  source = "xunleii/k3s/module"

  cluster_domain = format(local.name_format, "cluster")
  k3s_version    = "latest"
  use_sudo       = true

  servers = {
    for i in range(length(hcloud_server.manager)) : hcloud_server.manager[i].name => {
      ip = tolist(hcloud_server.manager[i].network)[0].ip
      connection = {
        host        = hcloud_server.manager[i].ipv4_address
        user        = local.ssh_user
        private_key = file(var.ssh_key)
        port        = var.ssh_port
      }
    }
  }

  agents = {}

  depends_on = [
    ssh_resource.manager_ready,
    ssh_resource.workers_ready,
  ]
}
