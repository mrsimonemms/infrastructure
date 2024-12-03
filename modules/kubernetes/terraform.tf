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

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.14.0, < 3.0.0"
    }
    infisical = {
      source  = "infisical/infisical"
      version = ">= 0.12.4, < 1.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.31.0, < 3.0.0"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = try(local.kubeconfig_by_context[var.kube_context].server, null)
    client_certificate     = try(base64decode(local.kubeconfig_by_context[var.kube_context].client-certificate-data), null)
    client_key             = try(base64decode(local.kubeconfig_by_context[var.kube_context].client-key-data), null)
    cluster_ca_certificate = try(base64decode(local.kubeconfig_by_context[var.kube_context].certificate-authority-data), null)
  }
}

provider "infisical" {
  client_id     = var.infisical_client_id
  client_secret = var.infisical_client_secret
}

provider "kubernetes" {
  host                   = try(local.kubeconfig_by_context[var.kube_context].server, null)
  client_certificate     = try(base64decode(local.kubeconfig_by_context[var.kube_context].client-certificate-data), null)
  client_key             = try(base64decode(local.kubeconfig_by_context[var.kube_context].client-key-data), null)
  cluster_ca_certificate = try(base64decode(local.kubeconfig_by_context[var.kube_context].certificate-authority-data), null)
}
