---
display_name: KasmVNC
description: A modern open source VNC server
icon: ../.icons/kasmvnc.svg
maintainer_github: coder
verified: true
tags: [helper, ide, VNC]
---

# KasmVNC

Automatically install [KasmVNC](https://kasmweb.com/kasmvnc) in a workspace, and create an app to access it via the dashboard.

## Examples

1. Add latest version of KasmVNC with [`lxde`](https://www.lxde.org/) desktop environment:

   ```hcl
   module "kasmvnc" {
     source   = "registry.coder.com/modules/kasmvnc/coder"
     version  = "1.0.0"
     agent_id = coder_agent.example.id
   }

   ```

2. Add specific version of KasmVNC with [`mate`](https://mate-desktop.org/) desktop environment and custom port:

   ```hcl
   module "kasmvnc" {
     source              = "registry.coder.com/modules/kasmvnc/coder"
     agent_id            = coder_agent.example.id
     version             = "1.0.0"
     desktop_environment = "mate"
     port                = 6080
   }

   ```
