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

![Jupyter Notebook](../.images/jupyter-notebook.png)

```tf
module "jupyter-notebook" {
  source   = "registry.coder.com/modules/jupyter-notebook/coder"
  version  = "1.0.2"
  agent_id = coder_agent.example.id
}
```
