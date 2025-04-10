---
display_name: devcontainers-cli
description: devcontainers-cli module provides an easy way to install @devcontainers/cli into a workspace
icon: ../.icons/devcontainers.svg
verified: true
tags: [devcontainers]
---

# devcontainers-cli

The devcontainers-cli module provides an easy way to install @devcontainers/cli into a workspace. It can be used within any workspace as it runs only if
@devcontainers/cli is not installed yet.
npm is required and should be installed in order for the module to work.

## Examples

```tf
module "devcontainers-cli" {
  source   = "registry.coder.com/modules/devcontainers-cli/coder"
  version  = "1.0.0"
  agent_id = coder_agent.example.id
}
```
