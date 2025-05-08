---
display_name: Windsurf Editor
description: Add a one-click button to launch Windsurf Editor
icon: ../.icons/windsurf.svg
maintainer_github: coder
verified: true
tags: [ide, windsurf, helper, ai]
---

# Windsurf Editor

Add a button to open any workspace with a single click in Windsurf Editor.

Uses the [Coder Remote VS Code Extension](https://github.com/coder/vscode-coder).

```tf
module "windsurf" {
  count    = data.coder_workspace.me.start_count
  source   = "registry.coder.com/modules/windsurf/coder"
  version  = "1.0.0"
  agent_id = coder_agent.example.id
}
```

## Examples

### Open in a specific directory

```tf
module "windsurf" {
  count    = data.coder_workspace.me.start_count
  source   = "registry.coder.com/modules/windsurf/coder"
  version  = "1.0.0"
  agent_id = coder_agent.example.id
  folder   = "/home/coder/project"
}
```
