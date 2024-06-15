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
  k3s_manager_labels = merge(local.labels, {
    format(local.label_namespace, "type") = "manager"
  })
  kubernetes_api_port = 6443
  labels = {
    format(local.label_namespace, "project")   = var.name
    format(local.label_namespace, "workspace") = local.workspace_name
  }
  label_namespace = "simonemms.com/%s"
  machine_user    = "k3s"
  name_format = join("-", [
    "infra",
    "%s", # name
    local.workspace_name
  ])
  workspace_name = replace(terraform.workspace, "/[\\W\\-]/", "") # alphanumeric workspace name
}
