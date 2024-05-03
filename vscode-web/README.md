---
display_name: VS Code Web
description: VS Code Web - Visual Studio Code in the browser
icon: ../.icons/code.svg
maintainer_github: coder
verified: true
tags: [helper, ide, vscode, web]
---

# VS Code Web

Automatically install [Visual Studio Code Server](https://code.visualstudio.com/docs/remote/vscode-server) in a workspace and create an app to access it via the dashboard.

```tf
module "vscode-web" {
  source         = "registry.coder.com/modules/vscode-web/coder"
  version        = "1.0.14"
  agent_id       = coder_agent.example.id
  accept_license = true
}
```

![VS Code Web with GitHub Copilot and live-share](../.images/vscode-web.gif)

## Examples

### Install VS Code Web to a custom folder

```tf
module "vscode-web" {
  source         = "registry.coder.com/modules/vscode-web/coder"
  version        = "1.0.14"
  agent_id       = coder_agent.example.id
  install_prefix = "/home/coder/.vscode-web"
  folder         = "/home/coder"
  accept_license = true
}
```

### Install Extensions

```tf
module "vscode-web" {
  source         = "registry.coder.com/modules/vscode-web/coder"
  version        = "1.0.14"
  agent_id       = coder_agent.example.id
  extensions     = ["github.copilot", "ms-python.python", "ms-toolsai.jupyter"]
  accept_license = true
}
```

### Pre-configure Settings

Configure VS Code's [settings.json](https://code.visualstudio.com/docs/getstarted/settings#_settingsjson) file:

```tf
module "vscode-web" {
  source     = "registry.coder.com/modules/vscode-web/coder"
  version    = "1.0.14"
  agent_id   = coder_agent.example.id
  extensions = ["dracula-theme.theme-dracula"]
  settings = {
    "workbench.colorTheme" = "Dracula"
  }
  accept_license = true
}
```
