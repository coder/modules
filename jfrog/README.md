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

Install the JF CLI and authenticate package managers with Artifactory.

![JFrog](../.images/jfrog.png)]

```hcl
module "jfrog" {
    source = "https://registry.coder.com/modules/jfrog"
    agent_id = coder_agent.example.id
    jfrog_host = "YYYY.jfrog.io"
    artifactory_access_token = var.artifactory_access_token # An admin access token
    package_managers = {
      "npm": "npm-local",
      "go": "go-local",
      "pypi": "pypi-local"
    }
}
```

## Authentication

Get a JFrog access token from your Artifactory instance. The token must have admin permissions. It is recommended to store the token in a secret terraform variable.

```hcl
variable "artifactory_access_token" {
    type      = string
    sensitive = true
}
```
