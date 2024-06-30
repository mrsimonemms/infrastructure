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
  global_ipv4_cidr = "0.0.0.0/0"
  global_ipv6_cidr = "::/0"
  labels = {
    format(local.label_namespace, "project")   = var.name
    format(local.label_namespace, "workspace") = local.workspace_name
  }
  k3s_manager_labels = merge(local.labels, {
    format(local.label_namespace, "type") = "manager"
  })
  k3s_worker_labels = merge(local.labels, {
    format(local.label_namespace, "type") = "worker"
  })
  k3s_worker_nodes = flatten([for w in var.k3s_worker_pools : [
    # If autoscaling, don't create any nodes
    for n in range(w.autoscaling.enabled ? 0 : w.count) :
    merge(
      w,
      {
        pool     = w.name
        name     = "${w.name}-${n}"
        location = w.location != null ? w.location : var.location
        labels = concat(
          // Add the pool name as a label
          [
            {
              key   = format(local.label_namespace, "pool"),
              value = w.name
            },
          ],
          w.labels,
        )
    })
  ]])
  kubernetes_api_port = 6443
  label_namespace     = "simonemms.com/%s"
  machine_user        = "k3s"
  name_format = join("-", [
    "hetzner",
    "%s", # resource name
    local.workspace_name
  ]) # use `format(local.name_format, "<name>")` to use this
  worker_placement_groups = {
    for i, w in hcloud_placement_group.workers : var.k3s_worker_pools[i].name => {
      id   = w.id
      name = w.name
    }
  }
  workspace_name = replace(var.workspace, "/[\\W]/", "") # alphanumeric workspace name
}
