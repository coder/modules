---
display_name: Windsurf IDE
description: Add a one-click button to launch Windsurf IDE
icon: ../.icons/windsurf.svg
maintainer_github: coder
verified: true
tags: [ide, windsurf, helper]
---

# Windsurf IDE

Add a button to open any workspace with a single click in Windsurf IDE.

Uses the [Coder Remote VS Code Extension](https://github.com/coder/vscode-coder).

```tf
module "windsurf" {
  source   = "registry.coder.com/modules/windsurf/coder"
  version  = "1.0.19"
  agent_id = coder_agent.example.id
}
```

## Examples

### Open in a specific directory

```tf
module "windsurf" {
  source   = "registry.coder.com/modules/windsurf/coder"
  version  = "1.0.19"
  agent_id = coder_agent.example.id
  folder   = "/home/coder/project"
}
```
