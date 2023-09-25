---
display_name: JetBrains Gateway
description: Add a one-click button to launch JetBrains Gateway IDEs in the dashboard.
icon: ../.icons/gateway.svg
maintainer_github: coder
verified: true
tags: [ide, jetbrains, helper]
---
# JetBrains Gateway

This module adds a JetBrains Gateway Button to open any workspace with a single click.

## Examples

### Add GoLand and WebStorm with the default set to GoLand

```hcl
module "jetbrains_gateway" {
  source                   = "https://registry.coder.com/modules/jetbrains-gateway"
  agent_id                 = coder_agent.example.id
  agent_name               = "example"
  project_directory        = "/home/coder/example"
  jetbrains_ides           = ["GO", "WS"]
  default                  = "GO"
}
```

### Add CLion and Idea with no D=deafult

```hcl
module "jetbrains_gateway" {
  source                   = "https://registry.coder.com/modules/jetbrains-gateway"
  agent_id                 = coder_agent.example.id
  agent_name               = "example"
  project_directory        = "/home/coder/example"
  jetbrains_ides           = ["IU", "CL"]
}
```

## Supported IDEs

This module and JetBrains Gateway support the following JetBrains IDEs:

- GoLand (`GO`)
- WebStorm (`WS`)
- IntelliJ IDEA Ultimate (`IU`)
- IntelliJ IDEA Community (`IC`)
- PyCharm Professional (`PY`)
- PyCharm Community (`PC`)
- PhpStorm (`PS`)
- CLion (`CL`)
- RubyMine (`RM`)
- DataGrip (`DB`)
- Rider (`RD`)
