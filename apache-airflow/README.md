---
display_name: airflow
description: A module that adds Apache Airflow in your Coder template
icon: ../.icons/airflow.svg
maintainer_github: coder
partner_github: nataindata
verified: true
tags: [airflow, idea, web, helper]
---

# airflow

A module that adds Apache Airflow in your Coder template.

```tf
module "airflow" {
  source   = "registry.coder.com/modules/apache-airflow/coder"
  version  = "1.0.13"
  agent_id = coder_agent.example.id
}
```

![Airflow](../.images/airflow.png)

## Examples

### Example 1

Install the Dracula theme from [OpenVSX](https://open-vsx.org/):

```tf
module "airflow" {
  source   = "registry.coder.com/modules/apache-airflow/coder"
  version  = "1.0.13"
  agent_id = coder_agent.example.id
  extensions = [
    "dracula-theme.theme-dracula"
  ]
}
```

Enter the `<author>.<name>` into the extensions array and code-server will automatically install on start.

### Example 2

Configure VS Code's [settings.json](https://code.visualstudio.com/docs/getstarted/settings#_settingsjson) file:

```tf
module "airflow" {
  source     = "registry.coder.com/modules/apache-airflow/coder"
  version    = "1.0.13"
  agent_id   = coder_agent.example.id
  extensions = ["dracula-theme.theme-dracula"]
  settings = {
    "workbench.colorTheme" = "Dracula"
  }
}
```

### Example 3

Run code-server in the background, don't fetch it from GitHub:

```tf
module "airflow" {
  source   = "registry.coder.com/modules/apache-airflow/coder"
  version  = "1.0.13"
  agent_id = coder_agent.example.id
  offline  = true
}
```
