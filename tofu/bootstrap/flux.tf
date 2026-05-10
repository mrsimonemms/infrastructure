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

# Flux bootstrap is run via the `flux` CLI rather than the FluxCD provider.
# Two reasons:
#   * The CLI is the canonical way to bootstrap and it is already documented.
#   * The provider needs a working kubeconfig at plan time, which forces a
#     two-phase apply with `-target`. Wrapping the CLI in a `terraform_data`
#     keeps the dependency on the kubeconfig file local to this resource.
#
# Re-runs are intentionally cheap: `flux bootstrap github` is idempotent and
# will reconcile drift. We only force a re-run when the kubeconfig changes
# (i.e. a brand-new cluster) or when the Flux target settings change.

resource "terraform_data" "flux_bootstrap" {
  count = var.enable_flux_bootstrap ? 1 : 0

  triggers_replace = {
    kubeconfig    = terraform_data.fetch_kubeconfig.id
    github_owner  = var.github_owner
    github_repo   = var.github_repository
    github_branch = var.github_branch
    target_path   = var.flux_target_path
  }

  provisioner "local-exec" {
    interpreter = ["/usr/bin/env", "bash", "-c"]
    environment = {
      KUBECONFIG   = var.kubeconfig_output_path
      GITHUB_TOKEN = var.github_token
    }
    command = <<-EOT
      set -euo pipefail

      if ! command -v flux >/dev/null 2>&1; then
        echo "flux CLI not found on PATH - install it from https://fluxcd.io/flux/installation/" >&2
        exit 1
      fi

      flux bootstrap github \
        --owner='${var.github_owner}' \
        --repository='${var.github_repository}' \
        --branch='${var.github_branch}' \
        --path='${var.flux_target_path}' \
        --personal=true
    EOT
  }
}

# Notes for future iterations:
#   * If/when Flux moves to a GitHub App or deploy-key flow, swap the
#     --personal flag and provide the appropriate creds via env vars.
#   * Image automation controllers can be enabled by adding
#     `--components-extra=image-reflector-controller,image-automation-controller`
#     to the bootstrap command. Wire them via a new variable when needed.
