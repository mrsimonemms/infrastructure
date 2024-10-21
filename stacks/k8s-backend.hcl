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

locals {
  workspace = basename(dirname(get_terragrunt_dir()))
}

inputs = {
  workspace = local.workspace
}

# Use Kubernetes backend
generate "remote_state" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "kubernetes" {
    secret_suffix = "state"
    config_path = "~/.kube/config"
    namespace = "kube-system"
  }
}
EOF
}
