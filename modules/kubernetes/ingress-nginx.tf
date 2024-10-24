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

# Deploy via Terraform to ensure load balancer is stopped when destroying infra

resource "random_integer" "ingress_load_balancer_id" {
  min = 1000
  max = 9999
}

resource "helm_release" "ingress_nginx" {
  chart            = "ingress-nginx"
  name             = "ingress-nginx"
  atomic           = true
  cleanup_on_fail  = true
  create_namespace = true
  namespace        = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  reset_values     = true
  version          = var.ingress_nginx_version
  wait             = true

  values = [
    templatefile("${path.module}/files/ingress-nginx.yaml", {
      location = var.load_balancer_location
      name     = "k3s-${random_integer.ingress_load_balancer_id.result}"
      type     = var.load_balancer_type
    })
  ]

  # Depend upon the HCloud CCM to allow the load balancer to be deleted on-destroy
  depends_on = [
    helm_release.hcloud_ccm,
    helm_release.hcloud_csi,
  ]
}
