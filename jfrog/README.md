---
display_name: JFrog
description: Install the JF CLI and authenticate with Artifactory
icon: ../.icons/jfrog.svg
maintainer_github: coder
partner_github: jfrog
verified: true
tags: [integration]
---

# JFrog

<!-- Describes what this module does -->

<!-- Add a screencast or screenshot here  put them in .images directory -->

```hcl
module "jfrog" {
    source = "https://registry.coder.com/modules/jfrog"

}
```

## Examples

### Example 1

Install the Dracula theme from [OpenVSX](https://open-vsx.org/):

```hcl
module "jfrog" {
    source = "https://registry.coder.com/modules/jfrog"
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
module "jfrog" {
    source = "https://registry.coder.com/modules/jfrog"
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
module "jfrog" {
    source = "https://registry.coder.com/modules/jfrog"
    agent_id = coder_agent.example.id
    offline = true
}
```
