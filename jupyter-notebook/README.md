---
display_name: Jupyter Notebook
description: A module that adds Jupyter Notebook in your Coder template.
icon: ../.icons/jupyter.svg
maintainer_github: coder
verified: true
tags: [jupyter, helper, ide, web]
---

# Jupyter Notebook

A module that adds Jupyter Notebook in your Coder template.

```tf
module "jupyter-notebook" {
  source   = "registry.coder.com/modules/jupyter-notebook/coder"
  version  = "1.0.23"
  agent_id = coder_agent.example.id
}
```

![Jupyter Notebook](../.images/jupyter-notebook.png)

## Examples

### Serve on a subpath (no wildcard subdomain)

```tf
module "jupyter-notebook" {
  source    = "registry.coder.com/modules/jupyter-notebook/coder"
  version   = "1.0.23"
  agent_id  = coder_agent.example.id
  subdomain = false
}
```

### Serve on a subpath with a specific agent name (multiple agents)

```tf
module "jupyter-notebook" {
  source     = "registry.coder.com/modules/jupyter-notebook/coder"
  version    = "1.0.23"
  agent_id   = coder_agent.example.id
  agent_name = "main"
}
```
