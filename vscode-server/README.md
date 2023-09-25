---
display_name: vscode-server
description: VS Code Web - Visual Studio Code in the browser
icon: ../.icons/code.svg
maintainer_github: coder
verified: true
tags: [helper, ide, vscode, web]
---

# VS Code Web

Automatically install [Visual Studio Code Server](https://code.visualstudio.com/docs/remote/vscode-server) in a workspace using the [VS Code CLIs](https://code.visualstudio.com/docs/editor/command-line) and create an app to access it via the dashboard.

![VS Code Server with GitHub Copilot and live-share](../.images/vscode-server.gif)

## Examples

1. Install VS Code Server with default settings:

   ```hcl
   module "vscode-web" {
     source         = "https://registry.coder.com/modules/vscode-server"
     agent_id       = coder_agent.example.id
     accept_license = true
   }
   ```

2. Install VS Code Server to a custom folder:

   ```hcl
   module "vscode-web" {
     source          = "https://registry.coder.com/modules/vscode-server"
     agent_id        = coder_agent.example.id
     install_dir     = "/home/coder/.vscode-server"
     folder          = "/home/coder"
     accept_license  = true
   }
   ```
