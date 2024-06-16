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

data "github_release" "csi_driver" {
  repository = var.hetzner_csi_driver_repo
  owner      = var.hetzner_csi_driver_owner

  retrieve_by = var.hetzner_csi_driver_version == "latest" ? var.hetzner_csi_driver_version : "tag"
  release_tag = var.hetzner_csi_driver_version != "latest" ? var.hetzner_csi_driver_version : null
}

data "github_repository_file" "csi_driver" {
  repository = "${var.hetzner_csi_driver_owner}/${var.hetzner_csi_driver_repo}"
  branch     = data.github_release.csi_driver.release_tag
  file       = "deploy/kubernetes/hcloud-csi.yml"
}

resource "local_file" "kubeconfig" {
  content  = local.k3s_kubeconfig
  filename = local.tmp_kubeconfig
}

resource "kubernetes_manifest" "csi_driver" {
  for_each = {
    for m in provider::kubernetes::manifest_decode_multi(data.github_repository_file.csi_driver.content) :
    m.metadata.name => m
  }
  manifest = each.value
}
