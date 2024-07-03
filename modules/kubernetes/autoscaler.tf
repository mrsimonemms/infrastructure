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

resource "kubernetes_namespace" "cluster_autoscaler" {
  count = length(var.worker_pools) > 0 ? 1 : 0

  metadata {
    name = "cluster-autoscaler"
  }
}

resource "kubernetes_secret_v1" "cluster_autoscaler" {
  count = length(var.worker_pools)

  metadata {
    name      = "hetzner-${var.worker_pools[count.index].pool.name}"
    namespace = kubernetes_namespace.cluster_autoscaler[0].metadata[0].name
  }

  data = {
    HCLOUD_TOKEN    = var.hcloud_token
    HCLOUD_NETWORK  = var.hcloud_network_name
    HCLOUD_FIREWALL = var.worker_pools[count.index].firewall_id
    HCLOUD_SSH_KEY  = var.worker_pools[count.index].ssh_key_id
    HCLOUD_CLUSTER_CONFIG = base64encode(jsonencode({
      imagesForArch = {
        arm64 = var.worker_pools[count.index].image
        amd64 = var.worker_pools[count.index].image
      }
      nodeConfigs = {
        (var.worker_pools[count.index].pool.name) = {
          cloudInit = var.worker_pools[count.index].cloud_init
          labels    = { for l in var.worker_pools[count.index].labels : l.key => l.value }
          taints    = var.worker_pools[count.index].taints
        }
      }
    }))
    HCLOUD_CLOUD_INIT = base64encode(var.worker_pools[count.index].cloud_init)
  }
}

resource "helm_release" "cluster_autoscaler" {
  count = length(var.worker_pools)

  chart           = "cluster-autoscaler"
  name            = "cluster-autoscaler-${var.worker_pools[count.index].pool.name}"
  atomic          = true
  cleanup_on_fail = true
  namespace       = kubernetes_namespace.cluster_autoscaler[0].metadata[0].name
  repository      = "https://kubernetes.github.io/autoscaler"
  reset_values    = true
  version         = var.cluster_autoscaler_version
  wait            = true

  set {
    name  = "cloudProvider"
    value = "hetzner"
  }

  set {
    name  = "envFromSecret"
    value = kubernetes_secret_v1.cluster_autoscaler[count.index].metadata[0].name
  }

  dynamic "set" {
    for_each = [for k, v in var.worker_pools[count.index].pool : {
      name  = "autoscalingGroups[0].${k}"
      value = v
    }]
    iterator = each

    content {
      name  = each.value.name
      value = each.value.value
    }
  }

  set {
    name  = "podAnnotations.secret"
    value = sha512(yamlencode(kubernetes_secret_v1.cluster_autoscaler[count.index].data))
  }
}
