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
  tfc_hostname     = "app.terraform.io"
  tfc_organization = "mrsimonemms"
  workspace        = "infra-${basename(dirname(get_terragrunt_dir()))}-${reverse(split("/", get_terragrunt_dir()))[0]}"
}

generate "remote_state" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "remote" {
    hostname = "${local.tfc_hostname}"
    organization = "${local.tfc_organization}"
    workspaces {
      name = "${local.workspace}"
    }
  }
}
EOF
}

inputs = {
  workspace = local.workspace
}
