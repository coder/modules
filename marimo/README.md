---
display_name: marimo
description: A module that adds marimo in your Coder template.
icon: ../.icons/marimo.svg
maintainer_github: coder
verified: true
tags: [marimo, python, notebook, reactive, helper, ide, web]
---

# marimo

A module that adds [marimo](https://github.com/marimo-team/marimo) in your Coder template.

marimo is a reactive Python notebook that's reproducible, git-friendly, and deployable as scripts or apps.

```tf
module "marimo" {
  count    = data.coder_workspace.me.start_count
  source   = "registry.coder.com/modules/marimo/coder"
  version  = "1.0.0"
  agent_id = coder_agent.example.id
}
```