---
display_name: VS Code Web
description: VS Code Web - Visual Studio Code in the browser
icon: ../.icons/code.svg
maintainer_github: coder
verified: true
tags: [helper, ide, vscode, web]
---

# VS Code Web

Automatically install [Visual Studio Code Server](https://code.visualstudio.com/docs/remote/vscode-server) in a workspace using the [VS Code CLI](https://code.visualstudio.com/docs/editor/command-line) and create an app to access it via the dashboard.

```hcl
module "vscode-web" {
  source         = "https://registry.coder.com/modules/vscode-web"
  agent_id       = coder_agent.example.id
  accept_license = true
}
```

![VS Code Web with GitHub Copilot and live-share](../.images/vscode-web.gif)

## Examples

### Install VS Code Web to a custom folder

```hcl
module "vscode-web" {
  source          = "https://registry.coder.com/modules/vscode-web"
  agent_id        = coder_agent.example.id
  install_dir     = "/home/coder/.vscode-web"
  folder          = "/home/coder"
  accept_license  = true
}
```
