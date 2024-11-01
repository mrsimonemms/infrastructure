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

  timeout = 10 * 60 # The Redis deployment can take it's sweet time

  values = [
    templatefile("${path.module}/files/argocd.yaml", {
      cluster_issuer = var.cluster_issuer
      domain         = "argocd.${var.domain}"
    })
  ]
}
