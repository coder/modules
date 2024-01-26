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

Install the JF CLI and authenticate package managers with Artifactory using Artifactory terraform provider.

```hcl
module "jfrog" {
  source = "registry.coder.com/modules/jfrog-token/coder"
  version = "1.0.1"
  agent_id = coder_agent.example.id
  jfrog_url = "https://XXXX.jfrog.io"
  artifactory_access_token = var.artifactory_access_token
  package_managers = {
    "npm": "npm",
    "go": "go",
    "pypi": "pypi"
  }
}
```

For detailed instructions, please see this [guide](https://coder.com/docs/v2/latest/guides/artifactory-integration#jfrog-token) on the Coder documentation.

> Note
> This module does not install `npm`, `go`, `pip`, etc but only configure them. You need to handle the installation of these tools yourself.

![JFrog](../.images/jfrog.png)

## Examples

### Configure npm, go, and pypi to use Artifactory local repositories

```hcl
module "jfrog" {
  source = "registry.coder.com/modules/jfrog-token/coder"
  version = "1.0.1"
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

You should now be able to install packages from Artifactory using both the `jf npm`, `jf go`, `jf pip` and `npm`, `go`, `pip` commands.

```shell
jf npm install prettier
jf go get github.com/golang/example/hello
jf pip install requests
```

```shell
npm install prettier
go get github.com/golang/example/hello
pip install requests
```

### Configure code-server with JFrog extension

The [JFrog extension](https://open-vsx.org/extension/JFrog/jfrog-vscode-extension) for VS Code allows you to interact with Artifactory from within the IDE.

```hcl
module "jfrog" {
  source = "registry.coder.com/modules/jfrog-token/coder"
  version = "1.0.1"
  agent_id = coder_agent.example.id
  jfrog_url = "https://XXXX.jfrog.io"
  artifactory_access_token = var.artifactory_access_token
  configure_code_server = true # Add JFrog extension configuration for code-server
  package_managers = {
    "npm": "npm",
    "go": "go",
    "pypi": "pypi"
  }
}
```

### Using the access token in other terraform resources

JFrog Access token is also available as a terraform output. You can use it in other terraform resources. For example, you can use it to configure an [Artifactory docker registry](https://jfrog.com/help/r/jfrog-artifactory-documentation/docker-registry) with the [docker terraform provider](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs).

```hcl

provider "docker" {
  ...
  registry_auth {
    address = "https://YYYY.jfrog.io/artifactory/api/docker/REPO-KEY"
    username = module.jfrog.username
    password = module.jfrog.access_token
  }
}
```
