# OpenTofu - Hetzner + k3s + Flux bootstrap

This OpenTofu configuration provisions the homelab control plane:

* a Hetzner Cloud private network and firewall,
* three k3s server (control-plane) nodes with embedded etcd,
* installation of k3s via cloud-init, and
* a one-shot `flux bootstrap github` against the freshly created cluster.

It deliberately stops at "the cluster exists and Flux owns the repo". All
ongoing Kubernetes resources are reconciled by Flux from
[`clusters/homelab`](../clusters/homelab) and **must not** be added to OpenTofu.

## Layout

```text
tofu/
├── versions.tf                  # Provider + tofu version pins
├── providers.tf                 # Provider configuration
├── variables.tf                 # Root variables
├── outputs.tf                   # Root outputs (kubeconfig path, public IPs, ...)
├── main.tf                      # Module wiring + shared resources (k3s token, SSH key)
├── backend.tf.example           # S3 backend skeleton (non-functional, ignored by tofu)
├── terraform.tfvars.example     # Variable skeleton (non-functional, ignored by tofu)
├── examples/                    # IDE-friendly templates (NOT auto-loaded - see below)
│   ├── backend.tf
│   └── terraform.tfvars
├── hetzner/                     # Hetzner Cloud infrastructure
│   ├── network.tf
│   ├── firewall.tf
│   ├── ssh.tf
│   ├── servers.tf
│   └── object-storage.tf
└── bootstrap/                   # Cluster + Flux bootstrap
    ├── cloud-init.yaml.tftpl
    ├── k3s.tf                   # cloud-init render + post-boot kubeconfig fetch
    └── flux.tf                  # `flux bootstrap github` runner
```

### Example configuration: `examples/` vs `*.example`

Two parallel template sets exist on purpose:

* `tofu/backend.tf.example` and `tofu/terraform.tfvars.example` are the
  documented copy targets. Their `.example` suffix means OpenTofu ignores
  them, but most editors do too - no syntax highlighting or schema hints.
* `tofu/examples/backend.tf` and `tofu/examples/terraform.tfvars` carry the
  same content with real `.tf` / `.tfvars` extensions so editors and
  `terraform-ls` light them up. They live in a subdirectory so OpenTofu
  does not pick them up: `tofu init/plan/apply` only loads `.tf` files in
  the working directory and modules referenced via `source = "./..."`,
  and nothing in `main.tf` references `examples/`.

Either source is safe to copy from - pick whichever your editor handles
best:

```sh
cp tofu/backend.tf.example       tofu/backend.tf       # or examples/backend.tf
cp tofu/terraform.tfvars.example tofu/terraform.tfvars # or examples/terraform.tfvars
```

`tofu/backend.tf` and `tofu/terraform.tfvars` (the live, secret-bearing
versions) are gitignored at the tofu root; the templates in `examples/`
are explicitly whitelisted so they stay committed.

## Local prerequisites

* `tofu` >= 1.7
* `ssh`, `scp` (used by local provisioners to fetch the kubeconfig)
* `flux` CLI (used by the Flux bootstrap step)
* `kubectl` (handy, not strictly required by OpenTofu)

## Required secrets / environment variables

| Purpose                               | Variable / env                                            |
| ------------------------------------- | --------------------------------------------------------- |
| Hetzner Cloud API token               | `hcloud_token` / `TF_VAR_hcloud_token`                    |
| GitHub PAT (Flux bootstrap)           | `github_token` / `TF_VAR_github_token` (needs `repo`)     |
| Cloudflare API token (optional)       | `cloudflare_api_token` / `TF_VAR_cloudflare_api_token`    |
| Hetzner Object Storage access key     | `AWS_ACCESS_KEY_ID` (used by the S3 backend)              |
| Hetzner Object Storage secret         | `AWS_SECRET_ACCESS_KEY` (used by the S3 backend)          |

Prefer environment variables over committing tokens to `terraform.tfvars`.

## First-time setup

1. **Create the Hetzner Object Storage bucket and access key**
   in the Hetzner Cloud Console (`Object Storage` -> create bucket
   `homelab-tofu-state` in the `nbg1` region, then create an access key).
   This step is manual because the bucket has to exist before OpenTofu can
   use it as a remote state backend.

2. **Copy the example var file** and edit it (either source works -
   `examples/terraform.tfvars` is the IDE-friendly twin of
   `terraform.tfvars.example`, see [Layout](#layout)):

   ```sh
   cp terraform.tfvars.example terraform.tfvars
   $EDITOR terraform.tfvars
   ```

   Set at minimum:
   * `hcloud_token`
   * `ssh_public_keys`
   * `allowed_ssh_cidrs`, `allowed_kube_api_cidrs`
   * `github_owner`, `github_token` (if `enable_flux_bootstrap = true`)

3. **Initialise OpenTofu** (local backend, first run):

   ```sh
   tofu init
   ```

4. **Move state to Hetzner Object Storage** (or copy from
   `examples/backend.tf` if you prefer):

   ```sh
   cp backend.tf.example backend.tf
   export AWS_ACCESS_KEY_ID=...      # Hetzner Object Storage access key
   export AWS_SECRET_ACCESS_KEY=...  # Hetzner Object Storage secret
   tofu init -migrate-state
   ```

## Apply

The first apply runs in two phases because the Flux bootstrap step needs the
cluster to be reachable:

```sh
# 1. Stand up the Hetzner infrastructure and let cloud-init bring up k3s.
tofu apply -target=module.hetzner

# 2. Fetch the kubeconfig and run `flux bootstrap github`.
tofu apply
```

Subsequent runs are just `tofu apply` - changes to cloud-init or node sizing
will trigger Hetzner-side recreation, but Flux state is owned by Git and will
not be re-bootstrapped after the first run unless `enable_flux_bootstrap`
flips back from `false` to `true`.

## Retrieving the kubeconfig

The fetched kubeconfig is written to `kubeconfig_output_path`
(default `./.kube/config`):

```sh
export KUBECONFIG="$(tofu output -raw kubeconfig_path)"
kubectl get nodes -o wide
```

You should see three Ready nodes labelled
`topology.simonemms.com/location=cloud` and
`node-role.simonemms.com/control-plane=true`.

## Verifying Flux

```sh
kubectl -n flux-system get kustomizations
kubectl -n flux-system get pods
flux check
flux get kustomizations
```

Expect `flux-system` to be ready, plus the placeholder Kustomizations for
`infrastructure`, `platform` and `apps` (all currently empty).

## Joining a Raspberry Pi as a worker (later)

Pi nodes will not run OpenTofu - they are provisioned by hand and joined to
the cluster as **worker only** (`agent`) nodes:

```sh
# On the Pi, as root, after a clean Ubuntu install:
curl -sfL https://get.k3s.io | \
  K3S_URL="https://<first-cp-public-ip>:6443" \
  K3S_TOKEN="<token from `tofu output -raw k3s_join_command`>" \
  INSTALL_K3S_EXEC="agent \
    --node-label topology.simonemms.com/location=home \
    --node-label node-role.simonemms.com/worker=true" \
  sh -
```

Notes:
* Pis must use `agent`, not `server` - control-plane membership is reserved
  for the three Hetzner nodes.
* `allowed_kube_api_cidrs` must include the Pi's outbound IP, **or** the Pi
  must reach the cluster via Tailscale / WireGuard (planned but not wired up
  yet).
* Labels follow the same `topology.simonemms.com` / `node-role.simonemms.com`
  convention; `topology.simonemms.com/location=home` lets workloads be pinned
  to home nodes once needed.
