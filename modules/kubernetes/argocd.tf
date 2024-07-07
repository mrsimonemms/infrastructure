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

resource "helm_release" "argocd" {
  chart            = "argo-cd"
  name             = "argocd"
  atomic           = true
  cleanup_on_fail  = true
  create_namespace = true
  namespace        = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  reset_values     = true
  version          = var.argocd_version
  wait             = true

  # Enable HA-mode with autoscaling
  # @link https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd#ha-mode-with-autoscaling
  set {
    name  = "redis-ha.enabled"
    value = "true"
  }

  set {
    name  = "repoServer.autoscaling.enabled"
    value = "true"
  }

  set {
    name  = "repoServer.autoscaling.minReplicas"
    value = "2"
  }

  set {
    name  = "server.autoscaling.enabled"
    value = "true"
  }

  set {
    name  = "server.autoscaling.minReplicas"
    value = "2"
  }

  set {
    name  = "global.domain"
    value = "argocd.simonemms.com"
  }

  set {
    name  = "configs.params.server.insecure"
    value = "true"
  }

  set {
    name  = "server.ingress.enabled"
    value = "true"
  }

  set {
    name  = "server.ingress.ingressClassName"
    value = "nginx"
  }

  set {
    name  = "server.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/force-ssl-redirect"
    value = "true"
  }

  set {
    name  = "server.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/backend-protocol"
    value = "HTTP"
  }

  # Allow running on control plane nodes
  dynamic "set" {
    for_each = flatten([
      for i, taint in local.control_plane_taints :
      [
        for k, v in taint :
        [
          {
            name  = "global.tolerations[${i}].${k}"
            value = v
          },
        ]
      ]
    ])
    iterator = each

    content {
      name  = each.value.name
      value = each.value.value
    }
  }

  depends_on = [helm_release.external_dns]
}
