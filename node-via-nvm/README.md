---
display_name: node-via-nvm
description: Install node via nvm
icon: ../.icons/node.svg
maintainer_github: coder
verified: true
tags: [helper]
---

# node-via-nvm

Automatically installs the latest version of [node](https://github.com/nodejs/node) versions via [nvm](https://github.com/nvm-sh/nvm). It can also install multiple versions of node and set a default version.

```tf
module "node-via-nvm" {
  source   = "registry.coder.com/modules/node-via-nvm/coder"
  version  = "1.0.2"
  agent_id = coder_agent.example.id
}
```

### Install multiple versions

This installs multiple versions of node

```tf
module "node-via-nvm" {
  source   = "registry.coder.com/modules/node-via-nvm/coder"
  version  = "1.0.2"
  agent_id = coder_agent.example.id
  node_versions = [
    "18",
    "20",
    "node"
  ]
  default_node_version = "20"
}
```

### Full example

A example with all available options:

```tf
module "node-via-nvm" {
  source             = "registry.coder.com/modules/node-via-nvm/coder"
  version            = "1.0.2"
  agent_id           = coder_agent.example.id
  nvm_version        = "v0.39.7"
  nvm_install_prefix = "/opt/nvm"
  node_versions = [
    "16",
    "18",
    "node"
  ]
  default_node_version = "16"
}
```
