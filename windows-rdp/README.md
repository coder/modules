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

```tf
# AWS example. See below for examples of using this module with other providers
module "windows_rdp" {
  count       = data.coder_workspace.me.start_count
  source      = "github.com/coder/modules//windows-rdp"
  agent_id    = resource.coder_agent.main.id
  resource_id = resource.aws_instance.dev.id
}
module "windows_rdp" {
  count       = data.coder_workspace.me.start_count
  source      = "github.com/coder/modules//windows-rdp"
  agent_id    = resource.coder_agent.main.id
  resource_id = resource.google_compute_instance.dev[0].id
}
```

## Video

<-- Insert demo video here -->

## Examples

### With AWS

```tf
module "windows_rdp" {
  count       = data.coder_workspace.me.start_count
  source      = "github.com/coder/modules//windows-rdp"
  agent_id    = resource.coder_agent.main.id
  resource_id = resource.aws_instance.dev.id
}
```

### With Google Cloud

```tf
module "windows_rdp" {
  count       = data.coder_workspace.me.start_count
  source      = "github.com/coder/modules//windows-rdp"
  agent_id    = resource.coder_agent.main.id
  resource_id = resource.google_compute_instance.dev[0].id
}
```

## Roadmap

- [ ] Test on Microsoft Azure.
