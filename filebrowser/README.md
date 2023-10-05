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

![Filebrowsing Example](../.images/filebrowser.png)

## Examples

### Serve a specific directory

```hcl
module "filebrowser" {
    source = "https://registry.coder.com/modules/filebrowser"
    agent_id = coder_agent.example.id
    folder = "/home/coder/project"
}
```

### Specify location of `filebrowser.db`

```hcl
module "filebrowser" {
    source = "https://registry.coder.com/modules/filebrowser"
    agent_id = coder_agent.example.id
    database_path = ".config/filebrowser.db"
}
```
