---
display_name: JetBrains Gateway
description: Add a one-click button to launch JetBrains Gateway IDEs in the dashboard.
icon: ../.icons/gateway.svg
maintainer_github: coder
verified: true
tags: [ide, jetbrains, helper, parameter]
---

# JetBrains Gateway

This module adds a JetBrains Gateway Button to open any workspace with a single click.

```tf
module "jetbrains_gateway" {
  source         = "registry.coder.com/modules/jetbrains-gateway/coder"
  version        = "1.0.11"
  agent_id       = coder_agent.example.id
  agent_name     = "example"
  folder         = "/home/coder/example"
  jetbrains_ides = ["CL", "GO", "IU", "PY", "WS"]
  default        = "GO"
}
```

![JetBrains Gateway IDes list](../.images/jetbrains-gateway.png)

## Examples

### Add GoLand and WebStorm as options with the default set to GoLand

```tf
module "jetbrains_gateway" {
  source         = "registry.coder.com/modules/jetbrains-gateway/coder"
  version        = "1.0.11"
  agent_id       = coder_agent.example.id
  agent_name     = "example"
  folder         = "/home/coder/example"
  jetbrains_ides = ["GO", "WS"]
  default        = "GO"
}
```

### Use the latest release version

```tf
module "jetbrains_gateway" {
  source         = "registry.coder.com/modules/jetbrains-gateway/coder"
  version        = "1.0.11"
  agent_id       = coder_agent.example.id
  agent_name     = "example"
  folder         = "/home/coder/example"
  jetbrains_ides = ["GO", "WS"]
  default        = "GO"
  latest         = true
}
```

### Use the latest EAP version

```tf
module "jetbrains_gateway" {
  source         = "registry.coder.com/modules/jetbrains-gateway/coder"
  version        = "1.0.11"
  agent_id       = coder_agent.example.id
  agent_name     = "example"
  folder         = "/home/coder/example"
  jetbrains_ides = ["GO", "WS"]
  default        = "GO"
  latest         = true
  channel        = "eap"
}
```

## Supported IDEs

This module and JetBrains Gateway support the following JetBrains IDEs:

- GoLand (`GO`)
- WebStorm (`WS`)
- IntelliJ IDEA Ultimate (`IU`)
- PyCharm Professional (`PY`)
- PhpStorm (`PS`)
- CLion (`CL`)
- RubyMine (`RM`)
- Rider (`RD`)
