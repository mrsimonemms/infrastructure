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

# IDE-friendly twin of ../terraform.tfvars.example.
#
# Lives here so editors / terraform-ls give .tfvars formatting and hints
# without OpenTofu auto-loading it. The tofu root only loads .tfvars from
# its own directory; this subdirectory is ignored at apply time.
#
# To use, copy to the tofu root:
#   cp tofu/examples/terraform.tfvars tofu/terraform.tfvars
# (or copy from tofu/terraform.tfvars.example).
# Then fill in real secrets and apply.

# --- Hetzner Cloud ---------------------------------------------------------
hcloud_token = "REPLACE_ME_WITH_64_CHAR_HCLOUD_PROJECT_TOKEN"

cluster_name        = "homelab"
hetzner_location    = "nbg1"
hetzner_server_type = "cx22"
hetzner_image       = "ubuntu-24.04"
node_count          = 3

# --- Networking ------------------------------------------------------------
network_cidr            = "10.0.0.0/16"
subnet_cidr             = "10.0.1.0/24"
control_plane_ip_offset = 10

# --- Access control --------------------------------------------------------
ssh_public_keys = [
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExampleKeyReplaceMe simon@laptop",
]

# Lock these down to your real source ranges. 0.0.0.0/0 is intentionally
# absent - dial them down to your home / VPN / Tailscale CIDRs.
allowed_ssh_cidrs      = ["203.0.113.42/32"]
allowed_kube_api_cidrs = ["203.0.113.42/32"]

# --- k3s -------------------------------------------------------------------
k3s_version  = "v1.31.4+k3s1"
k3s_tls_sans = ["k8s.example.com"]

cloud_node_labels = {
  "topology.simonemms.com/location"       = "cloud"
  "node-role.simonemms.com/control-plane" = "true"
}

# --- Flux bootstrap --------------------------------------------------------
enable_flux_bootstrap = true
github_owner          = "mrsimonemms"
github_repository     = "infrastructure"
github_branch         = "main"
# Personal access token with `repo` scope. Prefer `TF_VAR_github_token` over
# committing it here.
github_token = "REPLACE_ME_WITH_GITHUB_PAT"

flux_target_path = "clusters/homelab"

# --- Cloudflare (optional, unused at bootstrap) ----------------------------
# Wire this up when DNS records are added. Safe to leave empty until then.
cloudflare_api_token = ""

# --- Local outputs ---------------------------------------------------------
kubeconfig_output_path = "./.kube/config"
