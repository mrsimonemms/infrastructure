# Kubernetes

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.14.0, < 3.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.31.0, < 3.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6.2, < 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.14.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.31.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.hcloud_ccm](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.hcloud_csi](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_annotations.hcloud_ccm](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/annotations) | resource |
| [kubernetes_secret_v1.hcloud](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_hcloud_network_name"></a> [hcloud\_network\_name](#input\_hcloud\_network\_name) | Name of the network | `string` | n/a | yes |
| <a name="input_hcloud_token"></a> [hcloud\_token](#input\_hcloud\_token) | Write token for the Hetzner API | `string` | n/a | yes |
| <a name="input_hetzner_cloud_config_manager_version"></a> [hetzner\_cloud\_config\_manager\_version](#input\_hetzner\_cloud\_config\_manager\_version) | Version of the HCloud CCM to use - defaults to latest | `string` | `null` | no |
| <a name="input_hetzner_csi_driver_version"></a> [hetzner\_csi\_driver\_version](#input\_hetzner\_csi\_driver\_version) | Tag of the CSI driver to use - defaults to latest | `string` | `null` | no |
| <a name="input_k3s_cluster_cidr"></a> [k3s\_cluster\_cidr](#input\_k3s\_cluster\_cidr) | CIDR used for the k3s cluster | `string` | `"10.244.0.0/16"` | no |
| <a name="input_kube_context"></a> [kube\_context](#input\_kube\_context) | Kubernetes context to use | `string` | `"default"` | no |
| <a name="input_kubeconfig"></a> [kubeconfig](#input\_kubeconfig) | Kubeconfig for the cluster | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
