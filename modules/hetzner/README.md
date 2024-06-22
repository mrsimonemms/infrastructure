# Hetzner

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_hcloud"></a> [hcloud](#requirement\_hcloud) | >= 1.47.0, < 2.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_hcloud"></a> [hcloud](#provider\_hcloud) | 1.47.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [hcloud_firewall.name](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/firewall) | resource |
| [hcloud_network.network](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/network) | resource |
| [hcloud_network_subnet.subnet](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/network_subnet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_firewall_allow_api_access"></a> [firewall\_allow\_api\_access](#input\_firewall\_allow\_api\_access) | CIDR range to allow access to the Kubernetes API | `list(string)` | <pre>[<br>  "0.0.0.0/0",<br>  "::/0"<br>]</pre> | no |
| <a name="input_firewall_allow_ssh_access"></a> [firewall\_allow\_ssh\_access](#input\_firewall\_allow\_ssh\_access) | CIDR range to allow access to the servers via SSH | `list(string)` | <pre>[<br>  "0.0.0.0/0",<br>  "::/0"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | Name of project | `string` | `"infrastructure"` | no |
| <a name="input_network_subnet"></a> [network\_subnet](#input\_network\_subnet) | Subnet of the main network | `string` | `"10.0.0.0/16"` | no |
| <a name="input_network_type"></a> [network\_type](#input\_network\_type) | Type of network to use | `string` | `"cloud"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region to use. This covers multiple datacentres. | `string` | `"eu-central"` | no |
| <a name="input_ssh_port"></a> [ssh\_port](#input\_ssh\_port) | Port to use for SSH access | `number` | `22` | no |
| <a name="input_workspace"></a> [workspace](#input\_workspace) | Terraform workspace name | `string` | `"default"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
