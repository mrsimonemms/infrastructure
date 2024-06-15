# Infrastructure

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_hcloud"></a> [hcloud](#requirement\_hcloud) | >= 1.47.0 |
| <a name="requirement_ssh"></a> [ssh](#requirement\_ssh) | 2.7.0 |

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
| [hcloud_server.manager](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server) | resource |
| [hcloud_ssh_key.server](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/ssh_key) | resource |
| [ssh_resource.initial_manager](https://registry.terraform.io/providers/loafoe/ssh/2.7.0/docs/resources/resource) | resource |
| [ssh_resource.server_ready](https://registry.terraform.io/providers/loafoe/ssh/2.7.0/docs/resources/resource) | resource |
| [ssh_sensitive_resource.join_token](https://registry.terraform.io/providers/loafoe/ssh/2.7.0/docs/resources/sensitive_resource) | resource |
| [ssh_sensitive_resource.kubeconfig](https://registry.terraform.io/providers/loafoe/ssh/2.7.0/docs/resources/sensitive_resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_firewall_allow_api_access"></a> [firewall\_allow\_api\_access](#input\_firewall\_allow\_api\_access) | CIDR range to allow access to the Kubernetes API | `list(string)` | <pre>[<br>  "0.0.0.0/0",<br>  "::/0"<br>]</pre> | no |
| <a name="input_firewall_allow_ssh_access"></a> [firewall\_allow\_ssh\_access](#input\_firewall\_allow\_ssh\_access) | CIDR range to allow access to the servers via SSH | `list(string)` | <pre>[<br>  "0.0.0.0/0",<br>  "::/0"<br>]</pre> | no |
| <a name="input_k3s_download_url"></a> [k3s\_download\_url](#input\_k3s\_download\_url) | URL to download K3s from | `string` | `"https://get.k3s.io"` | no |
| <a name="input_k3s_manager_count"></a> [k3s\_manager\_count](#input\_k3s\_manager\_count) | Number of manager nodes to use. This must be an odd number. | `number` | `1` | no |
| <a name="input_k3s_manager_load_balancer_algorithm"></a> [k3s\_manager\_load\_balancer\_algorithm](#input\_k3s\_manager\_load\_balancer\_algorithm) | Algorithm to use for the k3s manager load balancer | `string` | `"round_robin"` | no |
| <a name="input_k3s_manager_load_balancer_type"></a> [k3s\_manager\_load\_balancer\_type](#input\_k3s\_manager\_load\_balancer\_type) | Load balancer type for the k3s manager nodes | `string` | `"lb11"` | no |
| <a name="input_k3s_manager_server_image"></a> [k3s\_manager\_server\_image](#input\_k3s\_manager\_server\_image) | Image to use for the k3s nodes | `string` | `"ubuntu-24.04"` | no |
| <a name="input_k3s_manager_server_type"></a> [k3s\_manager\_server\_type](#input\_k3s\_manager\_server\_type) | Server type of the k3s nodes | `string` | `"cx22"` | no |
| <a name="input_location"></a> [location](#input\_location) | Location to use. This is a single datacentre. | `string` | `"nbg1"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of project | `string` | `"infrastructure"` | no |
| <a name="input_network_subnet"></a> [network\_subnet](#input\_network\_subnet) | Subnet of the main network | `string` | `"10.0.0.0/16"` | no |
| <a name="input_network_type"></a> [network\_type](#input\_network\_type) | Type of network to use | `string` | `"cloud"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region to use. This covers multiple datacentres. | `string` | `"eu-central"` | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | Path to the private SSH key | `string` | `"~/.ssh/id_ed25519"` | no |
| <a name="input_ssh_key_public"></a> [ssh\_key\_public](#input\_ssh\_key\_public) | Path to the public SSH key | `string` | `"~/.ssh/id_ed25519.pub"` | no |
| <a name="input_ssh_port"></a> [ssh\_port](#input\_ssh\_port) | Port to use for SSH access | `number` | `22` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_k3s_join_token"></a> [k3s\_join\_token](#output\_k3s\_join\_token) | K3s join token for adding additional nodes |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Kubeconfig file |
<!-- END_TF_DOCS -->
