# `clusters/homelab` - Flux source of truth

Flux reconciles the homelab cluster from this directory. Everything below is
applied to the cluster automatically on commit; OpenTofu deliberately does
not touch any of it.

## Layout

```text
clusters/homelab/
├── flux-system/         # populated by `flux bootstrap` - do not hand-edit
├── infrastructure.yaml  # Flux Kustomization for ./infrastructure
├── platform.yaml        # Flux Kustomization for ./platform (depends on infrastructure)
├── apps.yaml            # Flux Kustomization for ./apps (depends on platform)
├── infrastructure/      # cluster infra (MetalLB, cert-manager, ESO, Tailscale, ...)
├── platform/            # shared platform services (Dex, Prometheus, Grafana, ...)
└── apps/                # end-user apps (Homepage, UniFi, ...)
```

The dependency chain `infrastructure -> platform -> apps` is enforced via
`spec.dependsOn` so that, for example, cert-manager is healthy before the
ingress-using platform services try to come up.

## Wiring up `flux-system/kustomization.yaml`

`flux bootstrap` writes three files into `flux-system/`:

* `gotk-components.yaml`
* `gotk-sync.yaml`
* `kustomization.yaml`

The default `kustomization.yaml` only references the two `gotk-*` files, so
Flux only sees `flux-system/`. To pull in `infrastructure.yaml`,
`platform.yaml` and `apps.yaml` from the parent directory, edit it to:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - gotk-components.yaml
  - gotk-sync.yaml
  - ../infrastructure.yaml
  - ../platform.yaml
  - ../apps.yaml
```

Commit + push and Flux picks up the three new Kustomizations on its next
reconcile cycle.

This step is documented rather than automated because `flux bootstrap` does
not overwrite an existing `kustomization.yaml`, but the operator still needs
to verify the gotk-* filenames before adding the parent references.

## Adding new components

* Cluster-level infra -> `infrastructure/`
* Shared platform service -> `platform/`
* User-facing app -> `apps/`

In each case: drop a manifest (or a `HelmRelease` + `HelmRepository`) into
the relevant directory and add it to that directory's `kustomization.yaml`
under `resources:`. Flux handles the rest.
