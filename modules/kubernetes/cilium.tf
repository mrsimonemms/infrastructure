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

resource "helm_release" "cilium" {
  chart           = "cilium"
  name            = "cilium"
  atomic          = true
  cleanup_on_fail = true
  namespace       = "kube-system"
  repository      = "https://helm.cilium.io"
  reset_values    = true
  version         = var.cilium_version
  wait            = true

  set {
    name  = "ipv4NativeRoutingCIDR"
    value = var.k3s_cluster_cidr
  }

  set {
    name  = "ipam.mode"
    value = "kubernetes"
  }
}
