#!/bin/bash
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


set -e

cd $(dirname "$0")

kubectl create namespace external-dns || true

kubectl create secret generic \
  cloudflare \
  -n external-dns \
  --from-literal cloudflare_api_token=${TF_VAR_cloudflare_api_token} \
  -o yaml \
  --dry-run=client | kubectl replace --force -f -

helm upgrade \
  --atomic \
  --cleanup-on-fail \
  --create-namespace \
  --install \
  --namespace external-dns \
  --reset-values \
  --wait \
  -f values.yaml \
  external-dns oci://registry-1.docker.io/bitnamicharts/external-dns
