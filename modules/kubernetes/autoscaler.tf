# # Copyright 2024 Simon Emms <simon@simonemms.com>
# #
# # Licensed under the Apache License, Version 2.0 (the "License");
# # you may not use this file except in compliance with the License.
# # You may obtain a copy of the License at
# #
# #     http://www.apache.org/licenses/LICENSE-2.0
# #
# # Unless required by applicable law or agreed to in writing, software
# # distributed under the License is distributed on an "AS IS" BASIS,
# # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# # See the License for the specific language governing permissions and
# # limitations under the License.

# resource "kubernetes_namespace" "cluster_autoscaler" {
#   metadata {
#     name = "cluster-autoscaler"
#   }

#   depends_on = [helm_release.cilium]
# }

# resource "kubernetes_secret_v1" "cluster_autoscaler" {
#   metadata {
#     name      = "hetzner"
#     namespace = kubernetes_namespace.cluster_autoscaler.metadata[0].name
#   }

#   data = {
#     HCLOUD_TOKEN    = var.hcloud_token
#     HCLOUD_NETWORK  = var.hcloud_network_name
#     HCLOUD_FIREWALL = var.hcloud_firewall_name
#     HCLOUD_SSH_KEY  = var.hcloud_ssh_key_id
#     HCLOUD_CLUSTER_CONFIG = base64encode(jsonencode({
#       imagesForArch = {
#         arm64 = var.k3s_manager_server_image
#         amd64 = var.k3s_manager_server_image
#       }
#       nodeConfigs = {
#         pool1 = {
#           cloudInit = templatefile("${path.module}/files/k3s-node.yaml", {
#             sshPort   = 2244
#             publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFuK1cZ/y6wgfWFdNTCtaOxbUUd7DCyd9oBtfoT+3GK simon@simonemms.com"
#             user      = "k3s"
#           })
#           labels = {
#             "node.kubernetes.io/role" = "autoscaler-node"
#           }
#         }
#       }
#     }))
#   }
# }

# locals {
#   autoscaler_autoscaling_groups = [
#     {
#       name         = "pool1"
#       minSize      = 4
#       maxSize      = 5
#       instanceType = "cx22"
#       region       = "nbg1"
#     },
#   ]
#   autoscaler_autoscaling_setter = flatten([for i, g in local.autoscaler_autoscaling_groups : [
#     for k, v in g : {
#       name  = "autoscalingGroups[${i}].${k}"
#       value = v
#     }
#   ]])
# }

# resource "helm_release" "cluster_autoscaler" {
#   chart           = "cluster-autoscaler"
#   name            = "cluster-autoscaler"
#   atomic          = true
#   cleanup_on_fail = true
#   namespace       = kubernetes_namespace.cluster_autoscaler.metadata[0].name
#   repository      = "https://kubernetes.github.io/autoscaler"
#   reset_values    = true
#   version         = var.cluster_autoscaler_version
#   wait            = true

#   set {
#     name  = "cloudProvider"
#     value = "hetzner"
#   }

#   set_sensitive {
#     name  = "envFromSecret"
#     value = kubernetes_secret_v1.cluster_autoscaler.metadata[0].name
#   }

#   dynamic "set_sensitive" {
#     for_each = local.autoscaler_autoscaling_setter
#     iterator = each

#     content {
#       name  = each.value.name
#       value = each.value.value
#     }
#   }

#   set_sensitive {
#     name  = "podAnnotations.secret"
#     value = sha512(yamlencode(kubernetes_secret_v1.cluster_autoscaler.data))
#   }
# }
