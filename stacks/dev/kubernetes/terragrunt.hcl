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
  source = "../../../modules/${basename(get_terragrunt_dir())}"
}

include {
  path = "../../common.hcl"
}

dependency "hetzner" {
  config_path = "../hetzner"

  mock_outputs = {
    hcloud_network_name = "some-network-name"
    k3s_cluster_cidr    = "some-cluster-cidr"
    kubeconfig          = "some-kubeconfig"
  }
}

inputs = {
  argocd_oidc_tls_skip_verify = true
  domain                      = "dev.simonemms.com"
  hcloud_network_name         = dependency.hetzner.outputs.hcloud_network_name
  infisical_environment_slug  = "dev"
  k3s_cluster_cidr            = dependency.hetzner.outputs.k3s_cluster_cidr
  kubeconfig                  = dependency.hetzner.outputs.kubeconfig
}
