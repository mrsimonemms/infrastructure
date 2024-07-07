# Custom Resources

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
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.31.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_manifest.cluster_issuers](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kube_context"></a> [kube\_context](#input\_kube\_context) | Kubernetes context to use | `string` | `"default"` | no |
| <a name="input_kubeconfig"></a> [kubeconfig](#input\_kubeconfig) | Kubeconfig for the cluster | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
