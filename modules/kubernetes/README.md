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
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.31.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.hcloud_ccm](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.hcloud_csi](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_annotations.hcloud_ccm](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/annotations) | resource |
| [kubernetes_namespace.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret_v1.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.hcloud](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_autoscaler_version"></a> [cluster\_autoscaler\_version](#input\_cluster\_autoscaler\_version) | Version of Cluster Autoscaler to use - defaults to latest | `string` | `null` | no |
| <a name="input_hcloud_network_name"></a> [hcloud\_network\_name](#input\_hcloud\_network\_name) | Hetzner network name | `string` | n/a | yes |
| <a name="input_hcloud_token"></a> [hcloud\_token](#input\_hcloud\_token) | Hetzner API token | `string` | n/a | yes |
| <a name="input_hetzner_cloud_config_manager_version"></a> [hetzner\_cloud\_config\_manager\_version](#input\_hetzner\_cloud\_config\_manager\_version) | Version of the HCloud CCM to use - defaults to latest | `string` | `null` | no |
| <a name="input_hetzner_csi_driver_version"></a> [hetzner\_csi\_driver\_version](#input\_hetzner\_csi\_driver\_version) | Tag of the CSI driver to use - defaults to latest | `string` | `null` | no |
| <a name="input_k3s_cluster_cidr"></a> [k3s\_cluster\_cidr](#input\_k3s\_cluster\_cidr) | CIDR used for the k3s cluster | `string` | `"10.244.0.0/16"` | no |
| <a name="input_kube_context"></a> [kube\_context](#input\_kube\_context) | Kubernetes context to use | `string` | `"default"` | no |
| <a name="input_kubeconfig"></a> [kubeconfig](#input\_kubeconfig) | Kubeconfig for the cluster | `string` | n/a | yes |
| <a name="input_worker_pools"></a> [worker\_pools](#input\_worker\_pools) | Cluster autoscaler configuration | <pre>list(object({<br>    cloud_init  = string<br>    firewall_id = string<br>    image       = string<br>    labels = list(object({<br>      key   = string<br>      value = string<br>    }))<br>    network_id = string<br>    pool = object({<br>      instanceType = string<br>      minSize      = number<br>      maxSize      = number<br>      name         = string<br>      region       = string<br>    })<br>    ssh_key_id = string<br>    taints = list(object({<br>      key    = string<br>      value  = string<br>      effect = string<br>    }))<br>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
