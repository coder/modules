---
display_name: Windows RDP
description: RDP Server and Web Client, powered by Devolutions Gateway
icon: ../.icons/desktop.svg
maintainer_github: coder
verified: true
tags: [windows, rdp, web, desktop]
---

# Windows RDP

Enable Remote Desktop + a web based client on Windows workspaces, powered by [devolutions-gateway](https://github.com/Devolutions/devolutions-gateway).

## Video

<-- Insert demo video here -->

## Usage

For AWS:

```tf
module "windows_rdp" {
  count       = data.coder_workspace.me.start_count
  source      = "github.com/coder/modules//windows-rdp"
  agent_id    = resource.coder_agent.main.id
  resource_id = resource.aws_instance.dev.id
}
```

For Google Cloud:

```tf
module "windows_rdp" {
  count       = data.coder_workspace.me.start_count
  source      = "github.com/coder/modules//windows-rdp"
  agent_id    = resource.coder_agent.main.id
  resource_id = resource.google_compute_instance.dev[0].id
}
```

## Tested on

- ✅ GCP with Windows Server 2022: [Example template](https://gist.github.com/bpmct/18918b8cab9f20295e5c4039b92b5143)

## Roadmap

- [ ] Test on Microsoft Azure.
