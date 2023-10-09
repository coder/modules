---
display_name: vault
description: Authenticates with Vault and injects secrets into the environment.
icon: ../.icons/vault.svg
maintainer_github: coder
verified: true
tags: [helper, integration, vault]
---

# Hashicorp Vault

This module authenticates with Vault and injects secrets into the environment.

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

### Configure Vault integration and automatically fetch secrets from Vault

Configure Vault integration and automatically fetch secrets from Vault and inject them into the workspace environment. This works by specifying the `secrets` variable with a list of secrets paths and keys to fetch from Vault. Multiple secrets can be specified by using a map of secret paths to a list of keys to fetch from each secret. For more information, see the [Vault documentation](https://www.vaultproject.io/api-docs/secret/kv/kv-v2#read-secret-version).

````hcl
For more information, see the [Vault documentation](https://www.vaultproject.io/docs/secrets/kv/kv-v2).

```hcl
module "vault" {
    source     = "https://registry.coder.com/modules/vault"
    vault_addr = "https://vault.example.com"
    secrets    = {
        "secret/data/foo" = ["FOO", "BAR"]
        "secret/data/bar" = ["BAZ"]
    }
}
````

### Configure Vault integration and install a specific version of the Vault CLI

```hcl
module "vault" {
    source = "https://registry.coder.com/modules/vault"
    vault_addr = "https://vault.example.com"
    vault_cli_version = "1.15.0"
}
```
