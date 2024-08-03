---
display_name: KasmVNC
description: A modern open source VNC server
icon: ../.icons/kasmvnc.svg
maintainer_github: coder
verified: true
tags: [helper, vnc, desktop]
---

# KasmVNC

Automatically install [KasmVNC](https://kasmweb.com/kasmvnc) in a workspace, and create an app to access it via the dashboard. Add latest version of KasmVNC with [`xfce`](https://xfce.org/) desktop environment.

```tf
module "kasmvnc" {
  source   = "registry.coder.com/modules/kasmvnc/coder"
  version  = "1.0.15"
  agent_id = coder_agent.example.id
}
```

> **Note:** This module only works on debian-based workspaces. It is recommended to use an image with a desktop environment pre-installed to speed up the installation process.
