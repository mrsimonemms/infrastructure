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

resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
  }
}

# resource "kubernetes_secret_v1" "github_secret" {
#   metadata {
#     name      = "github-oidc"
#     namespace = kubernetes_namespace_v1.argocd.metadata[0].name
#     labels = {
#       "app.kubernetes.io/part-of" = "argocd"
#     }
#   }

#   data = {
#     clientId     = var.argocd_github_client_id
#     clientSecret = var.argocd_github_client_secret
#   }
# }

resource "helm_release" "argocd" {
  chart            = "argo-cd"
  name             = "argocd"
  atomic           = true
  cleanup_on_fail  = true
  create_namespace = true
  namespace        = kubernetes_namespace_v1.argocd.metadata[0].name
  repository       = "https://argoproj.github.io/argo-helm"
  reset_values     = true
  version          = var.argocd_version
  wait             = true

  timeout = 10 * 60 # The Redis deployment can take it's sweet time

  values = [
    templatefile("${path.module}/files/argocd.yaml", {
      cluster_issuer = var.cluster_issuer
      dex_config     = {}
      # dex_config = {
      #   connectors = [
      #     {
      #       type = "github"
      #       id   = "github"
      #       name = "GitHub"
      #       config = {
      #         # Prepend with a $ so it looks for the secret
      #         clientID     = join("", ["$", "${kubernetes_secret_v1.github_secret.metadata[0].name}:clientId"])
      #         clientSecret = join("", ["$", "${kubernetes_secret_v1.github_secret.metadata[0].name}:clientSecret"])
      #         orgs = [
      #           {
      #             name  = var.argocd_github_org
      #             teams = flatten(values(var.argocd_github_teams))
      #           }
      #         ]
      #       }
      #     }
      #   ]
      # }
      oidc_config = {
        name   = "Dex"
        issuer = "https://dex.${var.domain}"
      }
      domain = "argocd.${var.domain}"
      policy = join("\n", concat(
        # org-admin policy
        [
          for resource in [
            "applications",
            "applicationsets",
            "clusters",
            "projects",
            "repositories",
            "accounts",
            "certificates",
            "gpgkeys",
            "logs",
            "exec",
            "extensions"
          ] : "p, role:org-admin, ${resource}, *, *, allow"
        ],
        # Assign GitHub org
        flatten([
          for role, teams in var.argocd_github_teams : [
            for team in teams : "g, ${var.argocd_github_org}:${team}, role:${role}"
          ]
        ])
      ))
    })
  ]

  depends_on = [
    helm_release.ingress_nginx
  ]
}
