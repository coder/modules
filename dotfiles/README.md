---
display_name: Dotfiles
description: Allow developers to optionally bring their own dotfiles repository to customize their shell and IDE settings!
icon: ../.icons/dotfiles.svg
maintainer_github: coder
verified: true
tags: [helper]
---

# Dotfiles

Allow developers to optionally bring their own [dotfiles repository](https://dotfiles.github.io).

This will prompt the user for their dotfiles repository URL on template creation using a `coder_parameter`.

Under the hood, this module uses the [coder dotfiles](https://coder.com/docs/v2/latest/dotfiles) command.

```tf
module "dotfiles" {
  source   = "registry.coder.com/modules/dotfiles/coder"
  version  = "1.0.0"
  agent_id = coder_agent.example.id
}
```

## Examples

### Apply dotfiles as the current user

```tf
module "dotfiles" {
  source   = "registry.coder.com/modules/dotfiles/coder"
  version  = "1.0.0"
  agent_id = coder_agent.example.id
}
```

### Apply dotfiles as root (only works if sudo is passwordless)

```tf
module "dotfiles" {
  source   = "registry.coder.com/modules/dotfiles/coder"
  version  = "1.0.0"
  agent_id = coder_agent.example.id
  user     = "root"
}
```

### Apply dotfiles as the current user and root (only works if sudo is passwordless)

```tf
module "dotfiles" {
  source   = "registry.coder.com/modules/dotfiles/coder"
  version  = "1.0.0"
  agent_id = coder_agent.example.id
}

module "dotfiles-root" {
  source       = "registry.coder.com/modules/dotfiles/coder"
  version      = "1.0.0"
  agent_id     = coder_agent.example.id
  user         = "root"
  dotfiles_uri = module.dotfiles.dotfiles_uri
}
```
