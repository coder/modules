---
display_name: Windows RDP
description: RDP Server and Web Client powered by Devolutions
icon: ../.icons/desktop.svg
maintainer_github: coder
verified: false
tags: [windows, ide, web]
---

# Windows RDP

Enable Remote Desktop + a web based client on Windows workspaces

<!-- TODO: Add GIF -->

## Usage

```tf
module "code-server" {
  source   = "registry.coder.com/modules/code-server/coder"
  version  = "1.0.10"
  agent_id = coder_agent.example.id
}
```

## Tested on

- ✅ GCP with Windows Server 2022: [Example template](https://gist.github.com/bpmct/18918b8cab9f20295e5c4039b92b5143)
