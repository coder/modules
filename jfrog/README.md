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

There are two ways to authenticate with Artifactory:

1. Using an admin access token
2. Using OAuth configured via Coder [`external-auth`](https://docs.coder.com/docs/admin/external-auth/) feature. This is the recommended approach.

Examples of both approaches are provided below.

## Examples

### Using an admin access token

```hcl
module "jfrog" {
  source = "https://registry.coder.com/modules/jfrog"
  agent_id = coder_agent.example.id
  jfrog_url = "https://YYYY.jfrog.io"
  artifactory_access_token = var.artifactory_access_token # An admin access token
  package_managers = {
    "npm": "npm",
    "go": "go",
    "pypi": "pypi"
  }
}
```

Get a JFrog access token from your Artifactory instance. The token must have admin permissions, i.e. with scopes = ["applied-permissions/admin"]. It is recommended to store the token in a secret terraform variable.

```hcl
variable "artifactory_access_token" {
  type      = string
  sensitive = true
}
```

![JFrog](../.images/jfrog.png)

### Using OAuth

You can use OAuth to authenticate with Artifactory. This is the recommended approach. To use OAuth, you must have the Coder [`external-auth`](https://coder.com/docs/v2/latest/admin/external-auth) configured with Artifactory.

![JFrog OAuth](../.images/jfrog-oauth.png)

```hcl
module "jfrog" {
  source = "https://registry.coder.com/modules/jfrog"
  agent_id = coder_agent.example.id
  jfrog_url = "https://YYYY.jfrog.io"
  auth_method = "oauth"
  username_field = "username" # If you are using GitHub to login to both Coder and Artifactory, use username_field = "username"
  package_managers = {
    "npm": "npm",
    "go": "go",
    "pypi": "pypi"
  }
}
```
