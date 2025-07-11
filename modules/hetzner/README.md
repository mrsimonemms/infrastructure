# Hetzner

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_hcloud"></a> [hcloud](#requirement\_hcloud) | >= 1.47.0, < 2.0.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.5.1, < 3.0.0 |
| <a name="requirement_ssh"></a> [ssh](#requirement\_ssh) | >= 2.7.0, < 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_hcloud"></a> [hcloud](#provider\_hcloud) | 1.48.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.1 |
| <a name="provider_ssh"></a> [ssh](#provider\_ssh) | 2.7.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_k3s"></a> [k3s](#module\_k3s) | github.com/mrsimonemms/terraform-module-k3s | n/a |

## Resources

| Name | Type |
|------|------|
| [hcloud_firewall.firewall](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/firewall) | resource |
| [hcloud_load_balancer.k3s_manager](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer) | resource |
| [hcloud_load_balancer_network.k3s_manager](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_network) | resource |
| [hcloud_load_balancer_service.k3s_manager](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_service) | resource |
| [hcloud_load_balancer_target.k3s_manager](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_target) | resource |
| [hcloud_network.network](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/network) | resource |
| [hcloud_network_subnet.subnet](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/network_subnet) | resource |
| [hcloud_placement_group.managers](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/placement_group) | resource |
| [hcloud_placement_group.workers](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/placement_group) | resource |
| [hcloud_server.manager](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server) | resource |
| [hcloud_server.workers](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server) | resource |
| [hcloud_ssh_key.server](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/ssh_key) | resource |
| [local_sensitive_file.kubeconfig](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [ssh_resource.manager_ready](https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/resource) | resource |
| [ssh_resource.workers_ready](https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_firewall_allow_api_access"></a> [firewall\_allow\_api\_access](#input\_firewall\_allow\_api\_access) | CIDR range to allow access to the Kubernetes API | `list(string)` | <pre>[<br/>  "0.0.0.0/0",<br/>  "::/0"<br/>]</pre> | no |
| <a name="input_firewall_allow_ssh_access"></a> [firewall\_allow\_ssh\_access](#input\_firewall\_allow\_ssh\_access) | CIDR range to allow access to the servers via SSH | `list(string)` | <pre>[<br/>  "0.0.0.0/0",<br/>  "::/0"<br/>]</pre> | no |
| <a name="input_k3s_manager_load_balancer_algorithm"></a> [k3s\_manager\_load\_balancer\_algorithm](#input\_k3s\_manager\_load\_balancer\_algorithm) | Algorithm to use for the k3s manager load balancer | `string` | `"round_robin"` | no |
| <a name="input_k3s_manager_load_balancer_type"></a> [k3s\_manager\_load\_balancer\_type](#input\_k3s\_manager\_load\_balancer\_type) | Load balancer type for the k3s manager nodes | `string` | `"lb11"` | no |
| <a name="input_k3s_manager_pool"></a> [k3s\_manager\_pool](#input\_k3s\_manager\_pool) | Manager pool configuration | <pre>object({<br/>    name        = optional(string, "manager")<br/>    server_type = optional(string, "cx22")<br/>    count       = optional(number, 1)<br/>    image       = optional(string, "ubuntu-24.04")<br/>  })</pre> | `{}` | no |
| <a name="input_k3s_worker_pools"></a> [k3s\_worker\_pools](#input\_k3s\_worker\_pools) | Worker pools configuration | <pre>list(object({<br/>    name        = string<br/>    server_type = optional(string, "cx22")<br/>    count       = optional(number, 1)<br/>    image       = optional(string, "ubuntu-24.04")<br/>    location    = optional(string) # Defaults to var.location if not set<br/>  }))</pre> | `[]` | no |
| <a name="input_kubeconfig_output_path"></a> [kubeconfig\_output\_path](#input\_kubeconfig\_output\_path) | Output path for the Kubeconfig | `string` | `"~/.kube/config"` | no |
| <a name="input_location"></a> [location](#input\_location) | Location to use. This is a single datacentre. | `string` | `"nbg1"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of project | `string` | `"k3s"` | no |
| <a name="input_network_subnet"></a> [network\_subnet](#input\_network\_subnet) | Subnet of the main network | `string` | `"10.0.0.0/16"` | no |
| <a name="input_network_type"></a> [network\_type](#input\_network\_type) | Type of network to use | `string` | `"cloud"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region to use. This covers multiple datacentres. | `string` | `"eu-central"` | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | Private SSH key | `string` | n/a | yes |
| <a name="input_ssh_key_public"></a> [ssh\_key\_public](#input\_ssh\_key\_public) | Public SSH key | `string` | n/a | yes |
| <a name="input_ssh_port"></a> [ssh\_port](#input\_ssh\_port) | Port to use for SSH access | `number` | `2244` | no |
| <a name="input_workspace"></a> [workspace](#input\_workspace) | Terraform workspace name | `string` | `"default"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hcloud_network_name"></a> [hcloud\_network\_name](#output\_hcloud\_network\_name) | Name of the network |
| <a name="output_k3s_cluster_cidr"></a> [k3s\_cluster\_cidr](#output\_k3s\_cluster\_cidr) | CIDR used for the k3s cluster |
| <a name="output_k3s_join_token"></a> [k3s\_join\_token](#output\_k3s\_join\_token) | Join token for k3s |
| <a name="output_kube_api_server"></a> [kube\_api\_server](#output\_kube\_api\_server) | Kubernetes API server address |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Kubeconfig |
| <a name="output_location"></a> [location](#output\_location) | Location to use. This is a single datacentre. |
| <a name="output_network_name"></a> [network\_name](#output\_network\_name) | Name of the network |
| <a name="output_pools"></a> [pools](#output\_pools) | Servers created |
| <a name="output_region"></a> [region](#output\_region) | Region to use. This covers multiple datacentres. |
| <a name="output_ssh_port"></a> [ssh\_port](#output\_ssh\_port) | SSH port for server |
| <a name="output_ssh_user"></a> [ssh\_user](#output\_ssh\_user) | SSH user for server |
<!-- END_TF_DOCS -->
