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

This module lets you fetch all or selective secrets from a [HCP Vault Secrets](https://developer.hashicorp.com/hcp/docs/vault-secrets) app into your Coder workspaces.

```tf
module "vault" {
  source   = "registry.coder.com/modules/hcp-vault-secrets/coder"
  version  = "1.0.3"
  agent_id = coder_agent.example.id
  app_name = "demo-app"
}
```

## Configuration

To configure the HCP Vault Secrets module, you must create an HCP Service Principal from the HCP Vault Secrets app in the HCP console. This will give you the `HCP_CLIENT_ID` and `HCP_CLIENT_SECRET` that you need to authenticate with HCP Vault Secrets. See the [HCP Vault Secrets documentation](https://developer.hashicorp.com/hcp/docs/vault-secrets) for more information.

## Fetch All Secrets

To fetch all secrets from the HCP Vault Secrets app, skip the `secrets` input.

```tf
module "vault" {
  source   = "registry.coder.com/modules/hcp-vault-secrets/coder"
  version  = "1.0.3"
  agent_id = coder_agent.example.id
  app_name = "demo-app"
}
```

## Fetch Selective Secrets

To fetch selective secrets from the HCP Vault Secrets app, set the `secrets` input.

```tf
module "vault" {
  source   = "registry.coder.com/modules/hcp-vault-secrets/coder"
  version  = "1.0.3"
  agent_id = coder_agent.example.id
  app_name = "demo-app"
  secrets  = ["MY_SECRET_1", "MY_SECRET_2"]
}
```

## Set Client ID and Client Secret as Inputs

Set `client_id` and `client_secret` as module inputs.

```tf
module "vault" {
  source        = "registry.coder.com/modules/hcp-vault-secrets/coder"
  version       = "1.0.3"
  agent_id      = coder_agent.example.id
  app_name      = "demo-app"
  client_id     = "HCP_CLIENT_ID"
  client_secret = "HCP_CLIENT_SECRET"
}
```
