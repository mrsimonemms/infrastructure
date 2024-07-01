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
  kubeconfig            = yamldecode(var.kubeconfig)
  kubeconfig_clusters   = { for context in local.kubeconfig.clusters : context.name => context.cluster }
  kubeconfig_users      = { for context in local.kubeconfig.users : context.name => context.user }
  kubeconfig_by_context = { for context, cluster in local.kubeconfig_clusters : context => merge(cluster, local.kubeconfig_users[context]) }
}
