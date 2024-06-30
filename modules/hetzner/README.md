# Hetzner

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_hcloud"></a> [hcloud](#requirement\_hcloud) | >= 1.47.0, < 2.0.0 |
| <a name="requirement_ssh"></a> [ssh](#requirement\_ssh) | >= 2.7.0, < 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_hcloud"></a> [hcloud](#provider\_hcloud) | 1.47.0 |
| <a name="provider_ssh"></a> [ssh](#provider\_ssh) | 2.7.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [hcloud_firewall.name](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/firewall) | resource |
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
| [ssh_resource.initial_manager](https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/resource) | resource |
| [ssh_resource.server_ready](https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/resource) | resource |
| [ssh_sensitive_resource.additional_managers](https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/sensitive_resource) | resource |
| [ssh_sensitive_resource.join_token](https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/sensitive_resource) | resource |
| [ssh_sensitive_resource.kubeconfig](https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/sensitive_resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_firewall_allow_api_access"></a> [firewall\_allow\_api\_access](#input\_firewall\_allow\_api\_access) | CIDR range to allow access to the Kubernetes API | `list(string)` | <pre>[<br>  "0.0.0.0/0",<br>  "::/0"<br>]</pre> | no |
| <a name="input_firewall_allow_ssh_access"></a> [firewall\_allow\_ssh\_access](#input\_firewall\_allow\_ssh\_access) | CIDR range to allow access to the servers via SSH | `list(string)` | <pre>[<br>  "0.0.0.0/0",<br>  "::/0"<br>]</pre> | no |
| <a name="input_k3s_cluster_cidr"></a> [k3s\_cluster\_cidr](#input\_k3s\_cluster\_cidr) | CIDR used for the k3s pod IPs | `string` | `"10.244.0.0/16"` | no |
| <a name="input_k3s_cluster_dns"></a> [k3s\_cluster\_dns](#input\_k3s\_cluster\_dns) | Cluster IP for CoreDNS. Should be in k3s\_server\_cidr range | `string` | `"10.43.0.10"` | no |
| <a name="input_k3s_download_url"></a> [k3s\_download\_url](#input\_k3s\_download\_url) | URL to download K3s from | `string` | `"https://get.k3s.io"` | no |
| <a name="input_k3s_manager_load_balancer_algorithm"></a> [k3s\_manager\_load\_balancer\_algorithm](#input\_k3s\_manager\_load\_balancer\_algorithm) | Algorithm to use for the k3s manager load balancer | `string` | `"round_robin"` | no |
| <a name="input_k3s_manager_load_balancer_type"></a> [k3s\_manager\_load\_balancer\_type](#input\_k3s\_manager\_load\_balancer\_type) | Load balancer type for the k3s manager nodes | `string` | `"lb11"` | no |
| <a name="input_k3s_manager_pool"></a> [k3s\_manager\_pool](#input\_k3s\_manager\_pool) | Manager pool configuration | <pre>object({<br>    name        = optional(string, "manager")<br>    server_type = optional(string, "cx22")<br>    count       = optional(number, 1)<br>    image       = optional(string, "ubuntu-24.04")<br>    labels = optional(<br>      list(object({<br>        key   = string<br>        value = string<br>      })),<br>      [],<br>    )<br>    taints = optional(<br>      list(object({<br>        key    = string<br>        value  = string<br>        effect = string<br>      })),<br>      []<br>    )<br>  })</pre> | `{}` | no |
| <a name="input_k3s_service_cidr"></a> [k3s\_service\_cidr](#input\_k3s\_service\_cidr) | CIDR used for the k3s service IPs | `string` | `"10.43.0.0/16"` | no |
| <a name="input_k3s_worker_pools"></a> [k3s\_worker\_pools](#input\_k3s\_worker\_pools) | Worker pools configuration | <pre>list(object({<br>    name        = string<br>    server_type = optional(string, "cx22")<br>    count       = optional(number, 1)<br>    image       = optional(string, "ubuntu-24.04")<br>    location    = optional(string) # Defaults to var.location if not set<br>    labels = optional(<br>      list(object({<br>        key   = string<br>        value = string<br>      })),<br>      [],<br>    )<br>    taints = optional(<br>      list(object({<br>        key    = string<br>        value  = string<br>        effect = string<br>      })),<br>      []<br>    )<br>    autoscaling = optional(<br>      object({<br>        enabled = bool<br>        min     = number<br>        max     = number<br>      }),<br>      {<br>        enabled = false<br>        min     = null<br>        max     = null<br>      },<br>    )<br>  }))</pre> | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | Location to use. This is a single datacentre. | `string` | `"nbg1"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of project | `string` | `"infrastructure"` | no |
| <a name="input_network_subnet"></a> [network\_subnet](#input\_network\_subnet) | Subnet of the main network | `string` | `"10.0.0.0/16"` | no |
| <a name="input_network_type"></a> [network\_type](#input\_network\_type) | Type of network to use | `string` | `"cloud"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region to use. This covers multiple datacentres. | `string` | `"eu-central"` | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | Path to the private SSH key | `string` | `"~/.ssh/id_ed25519"` | no |
| <a name="input_ssh_key_public"></a> [ssh\_key\_public](#input\_ssh\_key\_public) | Path to the public SSH key | `string` | `"~/.ssh/id_ed25519.pub"` | no |
| <a name="input_ssh_port"></a> [ssh\_port](#input\_ssh\_port) | Port to use for SSH access | `number` | `2244` | no |
| <a name="input_workspace"></a> [workspace](#input\_workspace) | Terraform workspace name | `string` | `"default"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hcloud_network_name"></a> [hcloud\_network\_name](#output\_hcloud\_network\_name) | Name of the network |
| <a name="output_k3s_cluster_cidr"></a> [k3s\_cluster\_cidr](#output\_k3s\_cluster\_cidr) | CIDR used for the k3s cluster |
| <a name="output_k3s_join_token"></a> [k3s\_join\_token](#output\_k3s\_join\_token) | K3s join token for adding additional nodes |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Kubeconfig file |
| <a name="output_location"></a> [location](#output\_location) | Location to use. This is a single datacentre. |
| <a name="output_region"></a> [region](#output\_region) | Region to use. This covers multiple datacentres. |
<!-- END_TF_DOCS -->
