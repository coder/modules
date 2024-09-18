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

```tf
module "filebrowser" {
  source     = "registry.coder.com/modules/filebrowser/coder"
  version    = "1.0.8"
  agent_id   = coder_agent.example.id
  agent_name = "main"
}
```

![Filebrowsing Example](../.images/filebrowser.png)

## Examples

### Serve a specific directory

```tf
module "filebrowser" {
  source     = "registry.coder.com/modules/filebrowser/coder"
  version    = "1.0.8"
  agent_id   = coder_agent.example.id
  agent_name = "main"
  folder     = "/home/coder/project"
}
```

### Specify location of `filebrowser.db`

```tf
module "filebrowser" {
  source        = "registry.coder.com/modules/filebrowser/coder"
  version       = "1.0.8"
  agent_id      = coder_agent.example.id
  agent_name    = "main"
  database_path = ".config/filebrowser.db"
}
```

### Serve from the same domain (no subdomain)

```tf
module "filebrowser" {
  source     = "registry.coder.com/modules/filebrowser/coder"
  agent_id   = coder_agent.example.id
  agent_name = "main"
  subdomain  = false
}
```
