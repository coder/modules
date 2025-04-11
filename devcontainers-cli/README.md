---
display_name: devcontainers-cli
description: devcontainers-cli module provides an easy way to install @devcontainers/cli into a workspace
icon: ../.icons/devcontainers.svg
verified: true
maintainer_github: coder
tags: [devcontainers]
---

# devcontainers-cli

The devcontainers-cli module provides an easy way to install @devcontainers/cli into a workspace. It can be used within any workspace as it runs only if
@devcontainers/cli is not installed yet.
npm is required and should be installed in order for the module to work.

```tf
module "devcontainers-cli" {
  source   = "registry.coder.com/modules/devcontainers-cli/coder"
  version  = "release/claude-code/1.0.32"
  agent_id = coder_agent.example.id
}
```
