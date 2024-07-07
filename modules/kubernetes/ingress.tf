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

resource "kubernetes_namespace_v1" "external_dns" {
  metadata {
    name = "external-dns"
  }

  wait_for_default_service_account = true
}

resource "kubernetes_secret_v1" "external_dns" {
  metadata {
    name      = "cloudflare"
    namespace = kubernetes_namespace_v1.external_dns.metadata[0].name
  }

  data = {
    cloudflare_api_token = var.cloudflare_api_token
  }
}

resource "helm_release" "external_dns" {
  chart           = "oci://registry-1.docker.io/bitnamicharts/external-dns"
  name            = "external-dns"
  atomic          = true
  cleanup_on_fail = true
  namespace       = kubernetes_namespace_v1.external_dns.metadata[0].name
  reset_values    = true
  version         = var.external_dns_version
  wait            = true

  set {
    name  = "provider"
    value = "cloudflare"
  }

  set {
    name  = "cloudflare.secretName"
    value = kubernetes_secret_v1.external_dns.metadata[0].name
  }

  set {
    name  = "podAnnotations.secret"
    value = sha512(yamlencode(kubernetes_secret_v1.external_dns.data))
  }
}

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

  dynamic "set" {
    for_each = {
      "load-balancer.hetzner.cloud/name"                    = "k3s-${random_integer.ingress_load_balancer_id.result}"
      "load-balancer.hetzner.cloud/network-zone"            = var.load_balancer_region
      "load-balancer.hetzner.cloud/type"                    = var.load_balancer_type
      "load-balancer.hetzner.cloud/disable-private-ingress" = "true"
      "load-balancer.hetzner.cloud/use-private-ip"          = "true"
      "load-balancer.hetzner.cloud/uses-proxyprotocol"      = "true"
    }
    content {
      name  = "controller.service.annotations.${replace(set.key, ".", "\\.")}"
      value = set.value
    }
  }

  set {
    name  = "controller.config.use-proxy-protocol"
    value = "true"
  }

  # Depend upon the HCloud CCM to allow the load balancer to be deleted on destroy
  depends_on = [
    helm_release.hcloud_ccm,
    helm_release.hcloud_csi,
  ]
}
