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

resource "kubernetes_secret_v1" "hcloud" {
  metadata {
    name      = "hcloud"
    namespace = "kube-system"
  }

  data = {
    network = var.hcloud_network_name # Required by the CCM
    token   = var.hcloud_token        # Required by the CSI
  }

  depends_on = [helm_release.cilium]
}

resource "helm_release" "hcloud_ccm" {
  chart           = "hcloud-cloud-controller-manager"
  name            = "hccm"
  atomic          = true
  cleanup_on_fail = true
  namespace       = "kube-system"
  repository      = "https://charts.hetzner.cloud"
  reset_values    = true
  version         = var.hetzner_cloud_config_manager_version
  wait            = true

  set {
    name  = "networking.enabled"
    value = "true"
  }

  set {
    name  = "networking.clusterCIDR"
    value = var.k3s_cluster_cidr
  }

  depends_on = [kubernetes_secret_v1.hcloud]
}

resource "kubernetes_annotations" "hcloud_ccm" {
  api_version = "apps/v1"
  kind        = "Deployment"
  metadata {
    name      = helm_release.hcloud_ccm.chart
    namespace = helm_release.hcloud_ccm.namespace
  }
  template_annotations = {
    "secret" = sha512(yamlencode(kubernetes_secret_v1.hcloud.data))
  }
}

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

resource "kubernetes_manifest" "csi_driver" {
  for_each = {
    for m in provider::kubernetes::manifest_decode_multi(data.github_repository_file.csi_driver.content) :
    "${m.apiVersion}.${m.kind}.${m.metadata.name}" => m
  }
  manifest = each.value

  // The hcloud-csi-controller deployment has 5 containers
  computed_fields = [
    "spec.template.spec.containers[0].resources",
    "spec.template.spec.containers[1].resources",
    "spec.template.spec.containers[2].resources",
    "spec.template.spec.containers[3].resources",
    "spec.template.spec.containers[4].resources",
  ]

  depends_on = [kubernetes_secret_v1.hcloud]
}
