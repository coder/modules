---
display_name: Dotfiles
description: Allow developers to optionally bring their own dotfiles repository to customize their shell and IDE settings!
icon: ../.icons/dotfiles.svg
maintainer_github: coder
verified: true
tags: [helper]
---

# Dotfiles

Allow developers to optionally bring their own [dotfiles repository](https://dotfiles.github.io)! Under the hood, this module uses the [coder dotfiles](https://coder.com/docs/v2/latest/dotfiles) command.

```hcl
module "dotfiles" {
  source = "https://registry.coder.com/modules/dotfiles"
  agent_id = coder_agent.example.id
}
```
