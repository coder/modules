---
display_name: Github Upload Public Key
description: Automates uploading Coder public key to Github so users don't have to.
icon: ../.icons/github.svg
maintainer_github: f0ssel
verified: false
tags: [helper]
---

# github-upload-public-key

<!-- Describes what this module does -->

```tf
module "github-upload-public-key" {
  source   = "registry.coder.com/modules/github-upload-public-key/coder"
  version  = "1.0.13"
  agent_id = coder_agent.example.id
}
```

<!-- Add a screencast or screenshot here  put them in .images directory -->

## Examples

### Example 1

Install the Dracula theme from [OpenVSX](https://open-vsx.org/):

```tf
module "MODULE_NAME" {
  source     = "registry.coder.com/modules/MODULE_NAME/coder"
  version    = "1.0.2"
  agent_id   = coder_agent.example.id
  extensions = [
    "dracula-theme.theme-dracula"
  ]
}
```

Enter the `<author>.<name>` into the extensions array and code-server will automatically install on start.

### Example 2

Configure VS Code's [settings.json](https://code.visualstudio.com/docs/getstarted/settings#_settingsjson) file:

```tf
module "MODULE_NAME" {
  source     = "registry.coder.com/modules/MODULE_NAME/coder"
  version    = "1.0.2"
  agent_id   = coder_agent.example.id
  extensions = [ "dracula-theme.theme-dracula" ]
  settings   = {
    "workbench.colorTheme" = "Dracula"
  }
}
```

### Example 3

Run code-server in the background, don't fetch it from GitHub:

```tf
module "MODULE_NAME" {
  source   = "registry.coder.com/modules/MODULE_NAME/coder"
  version  = "1.0.2"
  agent_id = coder_agent.example.id
  offline  = true
}
```
