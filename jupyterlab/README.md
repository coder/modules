---
display_name: JupyterLab
description: A module that adds JupyterLab in your Coder template.
icon: ../.icons/jupyter.svg
maintainer_github: coder
verified: true
tags: [jupyter, helper, ide, web]
---

# JupyterLab

A module that adds JupyterLab in your Coder template.

```tf
module "jupyterlab" {
  source   = "registry.coder.com/modules/jupyterlab/coder"
  version  = "1.0.23"
  agent_id = coder_agent.example.id
}
```

![JupyterLab](../.images/jupyterlab.png)

## Examples

### Serve on a subpath (no wildcard subdomain)

```tf
module "jupyterlab" {
  source    = "registry.coder.com/modules/jupyterlab/coder"
  version   = "1.0.23"
  agent_id  = coder_agent.example.id
  subdomain = false
}
```

### Serve on a subpath with a specific agent name (multiple agents)

```tf
module "jupyterlab" {
  source     = "registry.coder.com/modules/jupyterlab/coder"
  version    = "1.0.23"
  agent_id   = coder_agent.example.id
  agent_name = "main"
}
```
