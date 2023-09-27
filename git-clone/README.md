---
display_name: Git Clone
description: Clone a Git repository by URL and skip if it exists.
icon: ../.icons/git.svg
maintainer_github: coder
verified: true
tags: [git, helper]
---

# Git Clone

This module allows you to automatically clone a repository by URL and skip if it exists in the path provided.

```hcl
module "git-clone" {
    source   = "https://registry.coder.com/modules/git-clone"
    agent_id = coder_agent.example.id
    url      = "https://github.com/coder/coder"
}
```

To use with [Git Authentication](https://coder.com/docs/v2/latest/admin/git-providers), add the provider by ID to your template:

```hcl
data "coder_git_auth" "github" {
    id = "github"
}
```

## Examples

### Custom Path

```hcl
module "git-clone" {
    source   = "https://registry.coder.com/modules/git-clone"
    agent_id = coder_agent.example.id
    url      = "https://github.com/coder/coder"
    path     = "~/projects/coder/coder"
}
```
