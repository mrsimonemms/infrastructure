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

# Hetzner Object Storage
#
# This file is intentionally a placeholder. Hetzner Object Storage is
# managed outside the hcloud provider (the buckets and access keys live in
# the Cloud Console; the object API is S3-compatible).
#
# Two buckets are needed long-term:
#
#   1. <cluster>-tofu-state - holds OpenTofu remote state. This bucket has
#      to be created manually in the Hetzner Cloud Console *before* the S3
#      backend in `backend.tf` can be used (chicken-and-egg).
#
#   2. <cluster>-backups    - destination for future Velero / etcd /
#      application backups. Create this when the first backup workload
#      lands in `clusters/homelab/platform`.
#
# When/if it becomes worthwhile to manage these buckets in OpenTofu, add the
# `hashicorp/aws` provider with a Hetzner Object Storage endpoint and
# declare `aws_s3_bucket` resources here. Doing so today buys very little
# and forces every operator to carry an extra set of S3 credentials, so
# leave it out until there is a real need.
