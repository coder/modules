---
display_name: jupyterlab
description: Describe what this module does
icon: ../.icons/<A_RELEVANT_ICON>.svg
maintainer_github: GITHUB_USERNAME
verified: false
tags: [community]
---

# jupyterlab

<-- Describes what this module does -->

<-- Add a screencast or screenshot here -->

```hcl
module "jupyterlab" {
    source = "https://registry.coder.com/modules/jupyterlab"
}
```

## Examples

### Example 1

Install the Dracula theme from [OpenVSX](https://open-vsx.org/):

```hcl
module "jupyterlab" {
    source = "https://registry.coder.com/modules/jupyterlab"
    agent_id = coder_agent.example.id
    extensions = [
        "dracula-theme.theme-dracula"
    ]
}
```

Enter the `<author>.<name>` into the extensions array and code-server will automatically install on start.

### Example 2

Configure VS Code's [settings.json](https://code.visualstudio.com/docs/getstarted/settings#_settingsjson) file:

```hcl
module "jupyterlab" {
    source = "https://registry.coder.com/modules/jupyterlab"
    agent_id = coder_agent.example.id
    extensions = [ "dracula-theme.theme-dracula" ]
    settings = {
        "workbench.colorTheme" = "Dracula"
    }
}
```

### Example 3

Run code-server in the background, don't fetch it from GitHub:

```hcl
module "jupyterlab" {
    source = "https://registry.coder.com/modules/jupyterlab"
    agent_id = coder_agent.example.id
    offline = true
}
