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

provider "hcloud" {
  token = var.hcloud_token
}

# Cloudflare is wired up so DNS records can be added later (e.g. an A record
# for the Kubernetes API endpoint, or a wildcard for Traefik ingress).
# It is intentionally unused at bootstrap time - no records are created yet.
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
