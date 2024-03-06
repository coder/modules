---
display_name: VS Code Desktop
description: Add a one-click button to launch VS Code Desktop
icon: ../.icons/code.svg
maintainer_github: coder
verified: true
tags: [ide, vscode, helper]
---

# VS Code Desktop

Add a button to open any workspace with a single click.

Uses the [Coder Remote VS Code Extension](https://github.com/coder/vscode-coder).

```tf
module "vscode" {
  source   = "registry.coder.com/modules/vscode-desktop/coder"
  version  = "1.0.8"
  agent_id = coder_agent.example.id
}
```

## Examples

### Open in a specific directory

```tf
module "vscode" {
  source   = "registry.coder.com/modules/vscode-desktop/coder"
  version  = "1.0.8"
  agent_id = coder_agent.example.id
  folder   = "/home/coder/project"
}
```
