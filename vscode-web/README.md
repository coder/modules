---
display_name: vscode-web
description: VS Code Web - Visual Studio Code in the browser
icon: ../.icons/code.svg
maintainer_github: coder
verified: true
tags: [helper, ide, vscode, web]
---

# VS Code Web

Automatically install [VS Code](https://code.visualstudio.com) in a workspace, create an app to access it via the dashboard.

## Examples

1. Install VS Code Web with default settings:

   ```hcl
   module "vscode-web" {
       source         = "https://registry.coder.com/modules/vscode-web"
       agent_id       = coder_agent.example.id
       accept_license = true
   }
   ```

2. Install VS Code Web with custom version and folder

   ```hcl
   module "vscode-web" {
       source          = "https://registry.coder.com/modules/vscode-web"
       agent_id        = coder_agent.example.id
       version         = "1.82.0"
       folder          = "/home/coder/my-projet"
       accept_license  = true
   }
   ```
