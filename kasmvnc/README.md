---
display_name: KasmVNC
description: A modern open source VNC server
icon: ../.icons/kasmvnc.svg
maintainer_github: coder
verified: true
tags: [helper, vnc, desktop]
---

# KasmVNC

Automatically install [KasmVNC](https://kasmweb.com/kasmvnc) in a workspace, and create an app to access it via the dashboard.

```tf
module "kasmvnc" {
  source   = "registry.coder.com/modules/kasmvnc/coder"
  version  = "1.0.20"
  agent_id = coder_agent.example.id
}
```

> **Note:** This module only works on workspaces with a pre-installed desktop environment.
