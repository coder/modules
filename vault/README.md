---
display_name: vault
description: Authenticates with Vault
icon: ../.icons/vault.svg
maintainer_github: coder
verified: true
tags: [helper, integration, vault]
---

# Hashicorp Vault

This module lets you authenticate with [Hashicorp Vault](https://www.vaultproject.io/) in your Coder workspaces.

> **Note:** This module does not cover setting up and configuring Vault. For that, see the [Vault documentation](https://www.vaultproject.io/docs).

```hcl
module "vault" {
    source = "https://registry.coder.com/modules/vault"
    vault_addr = "https://vault.example.com"
}
```

![Vault login](../.images/vault-login.png)

## Examples

### Configure Vault integration with a custom Vault auth id

See [docs](https://coder.com/docs/v2/latest/admin/external-auth) for more information what are external auth ids.

```hcl
module "vault" {
    source = "https://registry.coder.com/modules/vault"
    vault_addr = "https://vault.example.com"
    vault_auth_id = "my-auth-id"
}
```

### Configure Vault integration and install a specific version of the Vault CLI

```hcl
module "vault" {
    source = "https://registry.coder.com/modules/vault"
    vault_addr = "https://vault.example.com"
    vault_cli_version = "1.15.0"
}
```
