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

> **Note:** This module does not cover setting up and configuring Vault auth methods. For that, see the [Vault documentation](https://developer.hashicorp.com/vault/docs/auth).

```hcl
module "vault" {
    source = "https://registry.coder.com/modules/vault"
    vault_addr = "https://vault.example.com"
}
```

Then you can use the Vault CLI in your workspaces to fetch secrets from Vault:

```shell
vault kv get secret/my-secret
```

or using the Vault API:

```shell
curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET $VAULT_ADDR/v1/secret/data/my-secret
```

![Vault login](../.images/vault-login.png)

## Configuration

To configure the Vault module, you must setup a Vault [OIDC Provider](https://developer.hashicorp.com/vault/docs/concepts/oidc-provider) and [configure](https://coder.com/docs/v2/latest/admin/external-auth) Coder to use it.

### OIDC Provider in Vault

1. Create a [Vault OIDC Application](https://developer.hashicorp.com/vault/tutorials/auth-methods/oidc-identity-provider) with name `coder` and set the Redirect URI to `https://coder.example.com/external-auth/vault/callback`.
2. Make note of the `Client ID` and `Client Secret`.
3. Add a provider to OIDC application with name `coder` and set the "Issuer URL" to `$VAULT_ADDR`.

### Coder configuration

Add the following to your Coder configuration:

```env
CODER_EXTERNAL_AUTH_0_ID: "vault"
CODER_EXTERNAL_AUTH_0_TYPE: "vault"
CODER_EXTERNAL_AUTH_0_CLIENT_ID: "XXXXXXXXXX"
CODER_EXTERNAL_AUTH_0_CLIENT_SECRET: "XXXXXXXXX"
CODER_EXTERNAL_AUTH_0_DISPLAY_NAME: "Hashicorp Vault"
CODER_EXTERNAL_AUTH_0_DISPLAY_ICON: "/icon/vault.svg"
CODER_EXTERNAL_AUTH_0_VALIDATE_URL: "$VAULT_ADDR/v1/identity/oidc/provider/coder/userinfo"
CODER_EXTERNAL_AUTH_0_AUTH_URL: "$VAULT_ADDR/ui/vault/identity/oidc/provider/coder/authorize"
CODER_EXTERNAL_AUTH_0_TOKEN_URL: "$VAULT_ADDR/v1/identity/oidc/provider/coder/token"
CODER_EXTERNAL_AUTH_0_SCOPES: "openid"
```

> **Note:** Replace `$VAULT_ADDR` with your Vault address. e.g. `https://vault.example.com`.

## Examples

### Configure Vault integration with a custom Vault auth id

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
