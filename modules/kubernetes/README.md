# Kubernetes

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.14.0, < 3.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.31.0, < 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.14.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.cilium](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cilium_version"></a> [cilium\_version](#input\_cilium\_version) | Version of Cilium to use - defaults to latest | `string` | `null` | no |
| <a name="input_k3s_cluster_cidr"></a> [k3s\_cluster\_cidr](#input\_k3s\_cluster\_cidr) | CIDR used for the k3s cluster | `string` | `"10.244.0.0/16"` | no |
| <a name="input_kube_context"></a> [kube\_context](#input\_kube\_context) | Kubernetes context to use | `string` | `"default"` | no |
| <a name="input_kubeconfig"></a> [kubeconfig](#input\_kubeconfig) | Kubeconfig for the cluster | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
