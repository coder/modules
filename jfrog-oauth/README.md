---
display_name: JFrog (OAuth)
description: Install the JF CLI and authenticate with Artifactory using OAuth.
icon: ../.icons/jfrog.svg
maintainer_github: coder
partner_github: jfrog
verified: true
tags: [integration, jfrog]
---

# JFrog

Install the JF CLI and authenticate package managers with Artifactory using OAuth configured via the Coder `external-auth` feature.

![JFrog OAuth](../.images/jfrog-oauth.png)

```hcl
module "jfrog" {
  source = "https://registry.coder.com/modules/jfrog-oauth"
  agent_id = coder_agent.example.id
  jfrog_url = "https://jfrog.example.com"
  auth_method = "oauth"
  username_field = "username" # If you are using GitHub to login to both Coder and Artifactory, use username_field = "username"
  package_managers = {
    "npm": "npm",
    "go": "go",
    "pypi": "pypi"
  }
}
```

## Prerequisites

- Coder [`external-auth`](https://docs.coder.com/docs/admin/external-auth/) configured with Artifactory. This requires a [custom integration](https://jfrog.com/help/r/jfrog-installation-setup-documentation/enable-new-integrations) in Artifactory with **Callback URL** set to `https://<your-coder-url>/external-auth/jfrog/callback`.

## Examples

Configure the Python pip package manager to fetch packages from Artifactory while mapping the Coder email to the Artifactory username.

```hcl
module "jfrog" {
  source = "https://registry.coder.com/modules/jfrog-oauth"
  agent_id = coder_agent.example.id
  jfrog_url = "https://jfrog.example.com"
  auth_method = "oauth"
  username_field = "email"
  package_managers = {
    "pypi": "pypi"
  }
}
```

You should now be able to install packages from Artifactory using both the `jf pip` and `pip` command.

```shell
jf pip install requests
```

```shell
pip install requests
```
