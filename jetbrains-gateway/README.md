# JetBrains Gateway (jetBrains-gateway) module

This module adds a JetBrains Gateway IDEs to your Coder template.

## How to use this module

To use this module, add the following snippet to your template manifest:

```hcl
module "jetbrains_gatway" {
  source = "git::https://github.com/coder/testing-modules.git//jetbrains-gateway"
  agent_id                 = coder_agent.main.id
  agent_name               = "main"
  project_directory        = "/home/coder"
  gateway_ide_product_code = ["GO","WS"] # A list of JetBrains product codes use ["ALL"] for all products
}
```

## Supported IDEs

The following JetBrains IDEs are supported:

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
