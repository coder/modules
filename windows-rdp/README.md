---
display_name: Windows RDP
description: RDP Server and Web Client powered by Devolutions
icon: ../.icons/desktop.svg
maintainer_github: coder
verified: false
tags: [windows, rdp, web, desktop]
---

# Windows RDP

Enable Remote Desktop + a web based client on Windows workspaces, powered by [devolutions-gateway](https://github.com/Devolutions/devolutions-gateway)

[![Web RDP on Windows](https://cdn.loom.com/sessions/thumbnails/a5d98c7007a7417fb572aba1acf8d538-with-play.gif)](https://www.loom.com/share/a5d98c7007a7417fb572aba1acf8d538)

## Usage

```tf
module "windows_rdp" {
  count = data.coder_workspace.me.start_count
  source = "github.com/coder/modules//windows-rdp?ref=web-rdp"
  agent_id = resource.coder_agent.main.id
  resource_id = resource.google_compute_instance.dev[0].id
}
```

## Tested on

- ✅ GCP with Windows Server 2022: [Example template](https://gist.github.com/bpmct/18918b8cab9f20295e5c4039b92b5143)

## Roadmap

- [ ] Test on additional cloud providers
- [ ] Automatically establish web RDP session
  > This may require forking [the webapp from devolutions-gateway](https://github.com/Devolutions/devolutions-gateway/tree/master/webapp)