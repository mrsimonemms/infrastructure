# Copyright 2026 Simon Emms <simon@simonemms.com>
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

# IDE-friendly twin of ../backend.tf.example.
#
# This file lives in tofu/examples/ on purpose:
#   * The .tf extension lets editors / terraform-ls / tflint treat it as
#     real OpenTofu code (syntax highlighting, schema hints, formatting).
#   * The directory is NOT auto-loaded by `tofu init/plan/apply` running in
#     tofu/ - OpenTofu only reads .tf files in the working directory and any
#     module it is explicitly pointed at via `source = "./..."`. Nothing in
#     the root config references this folder.
#
# To use it, copy to the tofu root:
#   cp tofu/examples/backend.tf tofu/backend.tf
# (or copy from tofu/backend.tf.example - both files have identical content).
# Then run `tofu init -migrate-state`.

terraform {
  backend "s3" {
    bucket = "homelab-tofu-state"
    key    = "homelab/terraform.tfstate"
    region = "nbg1"

    endpoints = {
      s3 = "https://nbg1.your-objectstorage.com"
    }

    # Hetzner Object Storage is S3-compatible but not AWS - skip the
    # AWS-specific validation paths.
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true

    # Access key + secret are read from environment variables:
    #   AWS_ACCESS_KEY_ID
    #   AWS_SECRET_ACCESS_KEY
    # (these are the Hetzner Object Storage credentials, not real AWS keys).
  }
}
