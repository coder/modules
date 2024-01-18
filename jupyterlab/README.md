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

![JupyterLab](../.images/jupyterlab.png)

```hcl
module "jupyterlab" {
  source = "registry.coder.com/modules/jupyterlab"
  version = "1.0.0"
  agent_id = coder_agent.example.id
}
```
