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
    secret = sha512(yamlencode(kubernetes_secret_v1.hcloud.data))
  }
}

resource "helm_release" "hcloud_csi" {
  chart           = "hcloud-csi"
  name            = "hcsi"
  atomic          = true
  cleanup_on_fail = true
  namespace       = "kube-system"
  repository      = "https://charts.hetzner.cloud"
  reset_values    = true
  version         = var.hetzner_csi_driver_version
  wait            = true

  set {
    name  = "controller.podAnnotations.secret"
    value = sha512(yamlencode(kubernetes_secret_v1.hcloud.data))
  }
}
