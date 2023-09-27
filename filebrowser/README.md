---
display_name: File Browser
description: A file browser for your workspace
icon: ../.icons/filebrowser.svg
maintainer_github: coder
verified: true
tags: [helper, filebrowser]
---

# File Browser

A file browser for your workspace.

```hcl
module "filebrowser" {
    source = "https://registry.coder.com/modules/filebrowser"
    agent_id = coder_agent.example.id
}
```

## Examples

### Serve a specific directory

```hcl
module "filebrowser" {
    source = "https://registry.coder.com/modules/filebrowser"
    agent_id = coder_agent.example.id
    folder = "/home/coder/project"
}
```
