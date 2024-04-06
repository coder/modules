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

[![Web RDP on Windows](https://cdn.loom.com/sessions/thumbnails/a5d98c7007a7417fb572aba1acf8d538-with-play.gif)](https://www.loom.com/share/a5d98c7007a7417fb572aba1acf8d538)

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

## Roadmap

- [ ] Test on additional cloud providers
- [ ] Automatically establish web RDP session
  > This may require forking [the webapp from devolutions-gateway](https://github.com/Devolutions/devolutions-gateway/tree/master/webapp)