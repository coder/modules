---
display_name: "HCP Vault Secrets"
description: "Fetch secrets from HCP Vault"
icon: ../.icons/vault.svg
maintainer_github: coder
partner_github: hashicorp
verified: true
tags: [helper, integration, vault, hashicorp, hvs]
---

# HCP Vault Secrets

This module lets you fetch secrets from [HCP Vault Secrets](https://developer.hashicorp.com/hcp/docs/vault-secrets) in your Coder workspaces.

```tf
module "vault" {
  source       = "registry.coder.com/modules/hcp-vault-secrets/coder"
  version      = "1.0.3"
  agent_id     = coder_agent.example.id
  app_name     = "demo-app"
  secrets_list = ["MY_SECRET_1", "MY_SECRET_2"]
}
```

## Configuration

To configure the HCP Vault Secrets module, you must create an HCP Service Principal from the HCP Vault Secrets app in the HCP console. This will give you the `HCP_CLIENT_ID` and `HCP_CLIENT_SECRET` that you need to authenticate with HCP Vault Secrets. See the [HCP Vault Secrets documentation](https://developer.hashicorp.com/hcp/docs/vault-secrets) for more information.

## Example

Set `client_id` and `client_secret` as module inputs.

```tf
module "vault" {
  source        = "registry.coder.com/modules/hcp-vault-secrets/coder"
  version       = "1.0.3"
  agent_id      = coder_agent.example.id
  app_name      = "demo-app"
  secrets_list  = ["MY_SECRET_1", "MY_SECRET_2"]
  client_id     = "HCP_CLIENT_ID"
  client_secret = "HCP_CLIENT_SECRET"
}
```
