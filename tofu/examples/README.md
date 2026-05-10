# `tofu/examples/`

Reference configuration for editors and humans. **Not loaded by OpenTofu.**

## Why this directory exists

`*.tf.example` and `*.tfvars.example` files at the tofu root are safe (the
extension is ignored by `tofu init/plan/apply`), but they get no IDE
support: editors do not know they are HCL, formatters skip them, and
`terraform-ls` cannot offer schema-aware help.

This directory holds the same templates with their real `.tf` / `.tfvars`
extensions so editors recognise them. OpenTofu does not recurse into
arbitrary subdirectories - it only reads `.tf` files in the working
directory and any module explicitly referenced via `source = "./..."`.
Nothing in the root config references `examples/`, so these files cannot be
applied accidentally.

## Files

| File               | Purpose                                               |
| ------------------ | ----------------------------------------------------- |
| `backend.tf`       | Hetzner Object Storage S3 backend (full, working).    |
| `terraform.tfvars` | Realistic variable values (placeholders for secrets). |

The root `tofu/backend.tf.example` and `tofu/terraform.tfvars.example`
files mirror these templates for the documented copy workflow:

```sh
cp tofu/backend.tf.example       tofu/backend.tf
cp tofu/terraform.tfvars.example tofu/terraform.tfvars
```

(Either source - `examples/foo` or `foo.example` - is fine; pick whichever
your editor prefers to read.)

## Safety

* No `.tf` file in the tofu root is an example.
* This directory is not a submodule and is not referenced from `main.tf`.
* `tofu/.gitignore` ignores live `tofu/backend.tf` and live `tofu/*.tfvars`
  while explicitly whitelisting `tofu/examples/*.tfvars`, so the templates
  here stay committed but real secrets cannot leak.
* No symlinks - templates are independent files.
