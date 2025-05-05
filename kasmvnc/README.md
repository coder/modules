---
display_name: KasmVNC
description: A modern open source VNC server
icon: ../.icons/kasmvnc.svg
maintainer_github: coder
verified: true
tags: [helper, vnc, desktop]
---

# KasmVNC

Automatically install [KasmVNC](https://kasmweb.com/kasmvnc) in a workspace, and
create an app to access it via the dashboard.

```tf
module "kasmvnc" {
  count               = data.coder_workspace.me.start_count
  source              = "registry.coder.com/modules/kasmvnc/coder"
  version             = "1.0.23"
  agent_id            = coder_agent.example.id
  desktop_environment = "xfce"
  subdomain           = true
}
```

> **Note:** This module only works on workspaces with a one of the following
> desktop environments pre-installed: `xfce`, `kde`, `gnome`, `lxde`, `lxqt`.

> The `codercom/enterprise-desktop` base image contains `xfce` and can be used
> as an example image.
