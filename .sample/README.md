---
display_name: MODULE_NAME
description: Describe what this module does
icon: ../.icons/<A_RELEVANT_ICON>.svg
maintainer_github: GITHUB_USERNAME
verified: false
tags: [helper]
---

# MODULE_NAME

<!-- Describes what this module does -->

<!-- Add a screencast or screenshot here -->

```hcl
module "MODULE_NAME" {
    source = "https://registry.coder.com/modules/MODULE_NAME"
}
```

## Examples

### Example 1

Install the Dracula theme from [OpenVSX](https://open-vsx.org/):

```hcl
module "MODULE_NAME" {
    source = "https://registry.coder.com/modules/MODULE_NAME"
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
module "MODULE_NAME" {
    source = "https://registry.coder.com/modules/MODULE_NAME"
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
module "MODULE_NAME" {
    source = "https://registry.coder.com/modules/MODULE_NAME"
    agent_id = coder_agent.example.id
    offline = true
}
```
