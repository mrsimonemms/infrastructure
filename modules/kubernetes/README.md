# Kubernetes

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_hcloud"></a> [hcloud](#requirement\_hcloud) | >= 1.49.1, < 2.0.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.14.0, < 3.0.0 |
| <a name="requirement_infisical"></a> [infisical](#requirement\_infisical) | >= 0.12.4, < 1.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.31.0, < 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_hcloud"></a> [hcloud](#provider\_hcloud) | 1.49.1 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.16.1 |
| <a name="provider_infisical"></a> [infisical](#provider\_infisical) | 0.12.8 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.35.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_config_map_v1.metallb](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1) | resource |
| [kubernetes_namespace_v1.argocd](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.external_secrets](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.metallb](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_secret_v1.bitwarden](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.infisical](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.oidc_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [hcloud_servers.manager_nodes](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/data-sources/servers) | data source |
| [infisical_secrets.common_secrets](https://registry.terraform.io/providers/infisical/infisical/latest/docs/data-sources/secrets) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argocd_github_org"></a> [argocd\_github\_org](#input\_argocd\_github\_org) | GitHub org to use for Dex OIDC | `string` | n/a | yes |
| <a name="input_argocd_github_teams"></a> [argocd\_github\_teams](#input\_argocd\_github\_teams) | GitHub teams to use for Dex OIDC | <pre>object({<br>    org-admin = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_argocd_oidc_tls_skip_verify"></a> [argocd\_oidc\_tls\_skip\_verify](#input\_argocd\_oidc\_tls\_skip\_verify) | Skip TLS verification for Argo OIDC provider | `bool` | `false` | no |
| <a name="input_argocd_version"></a> [argocd\_version](#input\_argocd\_version) | Version of ArgoCD to use - defaults to latest | `string` | `null` | no |
| <a name="input_bitwarden_token"></a> [bitwarden\_token](#input\_bitwarden\_token) | Bitwarden Secret Manager token | `string` | n/a | yes |
| <a name="input_cluster_issuer"></a> [cluster\_issuer](#input\_cluster\_issuer) | Cluster issuer to use for certificate | `string` | `"letsencrypt-staging"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the cluster | `string` | n/a | yes |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain to use - this may be a top-level or subdomain | `string` | n/a | yes |
| <a name="input_infisical_client_id"></a> [infisical\_client\_id](#input\_infisical\_client\_id) | Infisical client ID | `string` | n/a | yes |
| <a name="input_infisical_client_secret"></a> [infisical\_client\_secret](#input\_infisical\_client\_secret) | Infisical client secret | `string` | n/a | yes |
| <a name="input_infisical_environment_slug"></a> [infisical\_environment\_slug](#input\_infisical\_environment\_slug) | Infisical environment slug | `string` | n/a | yes |
| <a name="input_infisical_project_id"></a> [infisical\_project\_id](#input\_infisical\_project\_id) | Infisical project ID | `string` | n/a | yes |
| <a name="input_kubeconfig_path"></a> [kubeconfig\_path](#input\_kubeconfig\_path) | Kubeconfig for the cluster | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
