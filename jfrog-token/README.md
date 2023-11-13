---
display_name: JFrog (Token)
description: Install the JF CLI and authenticate with Artifactory using Artifactory terraform provider.
icon: ../.icons/jfrog.svg
maintainer_github: coder
partner_github: jfrog
verified: true
tags: [integration, jfrog]
---

# JFrog

Install the JF CLI and authenticate package managers with Artifactory.

```hcl
module "jfrog" {
    source = "https://registry.coder.com/modules/jfrog-token"
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

Get a JFrog access token from your Artifactory instance. The token must have admin permissions. It is recommended to store the token in a secret terraform variable.

```hcl
variable "artifactory_access_token" {
    type      = string
    sensitive = true
}
```

![JFrog](../.images/jfrog.png)

## Examples

### Configure npm, go, and pypi to use Artifactory local repositories

```hcl
module "jfrog" {
    source = "https://registry.coder.com/modules/jfrog-token"
    agent_id = coder_agent.example.id
    jfrog_url = "https://YYYY.jfrog.io"
    artifactory_access_token = var.artifactory_access_token # An admin access token
    package_managers = {
      "npm": "npm-local",
      "go": "go-local",
      "pypi": "pypi-local"
    }
}
```

You should now be able to install packages from Artifactory using both the `jf npm`, `jf go`, `jf pip` and `npm`, `go`, `pip` command.

```shell
jf npm install prettier
jf go get github.com/golang/example/hello
jf pip install requests
npm install prettier
go get github.com/golang/example/hello
pip install requests
```
