---
display_name: Personalize
description: Allow developers to customize their workspace on start
icon: ../.icons/personalize.svg
maintainer_github: coder
verified: true
tags: [helper]
---

# Personalize

Run a script on workspace start that allows developers to run custom commands to personalize their workspace.

```hcl
module "personalize" {
  source = "https://registry.coder.com/modules/personalize"
  agent_id = coder_agent.example.id
}
```
