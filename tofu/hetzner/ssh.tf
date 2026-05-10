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

resource "hcloud_ssh_key" "this" {
  for_each = {
    for idx, key in var.ssh_public_keys : format("%s-%d", var.cluster_name, idx) => key
  }

  name       = each.key
  public_key = each.value

  labels = {
    cluster = var.cluster_name
  }
}
