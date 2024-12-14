# Kubernetes

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.14.0, < 3.0.0 |
| <a name="requirement_infisical"></a> [infisical](#requirement\_infisical) | >= 0.12.4, < 1.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.31.0, < 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.14.1 |
| <a name="provider_infisical"></a> [infisical](#provider\_infisical) | 0.12.4 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.31.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.hcloud_ccm](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.hcloud_csi](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_config_map_v1.metallb](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1) | resource |
| [kubernetes_namespace_v1.argocd](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.external_secrets](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.metallb](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_secret_v1.bitwarden](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.hcloud](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.infisical](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.oidc_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [infisical_secrets.common_secrets](https://registry.terraform.io/providers/infisical/infisical/latest/docs/data-sources/secrets) | data source |
| [kubernetes_nodes.cluster](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/nodes) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argocd_github_org"></a> [argocd\_github\_org](#input\_argocd\_github\_org) | GitHub org to use for Dex OIDC | `string` | n/a | yes |
| <a name="input_argocd_github_teams"></a> [argocd\_github\_teams](#input\_argocd\_github\_teams) | GitHub teams to use for Dex OIDC | <pre>object({<br>    org-admin = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_argocd_oidc_tls_skip_verify"></a> [argocd\_oidc\_tls\_skip\_verify](#input\_argocd\_oidc\_tls\_skip\_verify) | Skip TLS verification for Argo OIDC provider | `bool` | `false` | no |
| <a name="input_argocd_version"></a> [argocd\_version](#input\_argocd\_version) | Version of ArgoCD to use - defaults to latest | `string` | `null` | no |
| <a name="input_bitwarden_token"></a> [bitwarden\_token](#input\_bitwarden\_token) | Bitwarden Secret Manager token | `string` | n/a | yes |
| <a name="input_cluster_issuer"></a> [cluster\_issuer](#input\_cluster\_issuer) | Cluster issuer to use for certificate | `string` | `"letsencrypt-staging"` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain to use - this may be a top-level or subdomain | `string` | n/a | yes |
| <a name="input_hcloud_network_name"></a> [hcloud\_network\_name](#input\_hcloud\_network\_name) | Name of the network | `string` | n/a | yes |
| <a name="input_hcloud_token"></a> [hcloud\_token](#input\_hcloud\_token) | Write token for the Hetzner API | `string` | n/a | yes |
| <a name="input_hetzner_cloud_config_manager_version"></a> [hetzner\_cloud\_config\_manager\_version](#input\_hetzner\_cloud\_config\_manager\_version) | Version of the HCloud CCM to use - defaults to latest | `string` | `null` | no |
| <a name="input_hetzner_csi_driver_version"></a> [hetzner\_csi\_driver\_version](#input\_hetzner\_csi\_driver\_version) | Tag of the CSI driver to use - defaults to latest | `string` | `null` | no |
| <a name="input_infisical_client_id"></a> [infisical\_client\_id](#input\_infisical\_client\_id) | Infisical client ID | `string` | n/a | yes |
| <a name="input_infisical_client_secret"></a> [infisical\_client\_secret](#input\_infisical\_client\_secret) | Infisical client secret | `string` | n/a | yes |
| <a name="input_infisical_environment_slug"></a> [infisical\_environment\_slug](#input\_infisical\_environment\_slug) | Infisical environment slug | `string` | n/a | yes |
| <a name="input_infisical_project_id"></a> [infisical\_project\_id](#input\_infisical\_project\_id) | Infisical project ID | `string` | n/a | yes |
| <a name="input_k3s_cluster_cidr"></a> [k3s\_cluster\_cidr](#input\_k3s\_cluster\_cidr) | CIDR used for the k3s cluster | `string` | `"10.244.0.0/16"` | no |
| <a name="input_kube_context"></a> [kube\_context](#input\_kube\_context) | Kubernetes context to use | `string` | `"default"` | no |
| <a name="input_kubeconfig"></a> [kubeconfig](#input\_kubeconfig) | Kubeconfig for the cluster | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
