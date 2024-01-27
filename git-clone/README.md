---
display_name: Git Clone
description: Clone a Git repository by URL and skip if it exists.
icon: ../.icons/git.svg
maintainer_github: coder
verified: true
tags: [git, helper]
---

# Git Clone

This module allows you to automatically clone a repository by URL and skip if it exists in the base directory provided.

```tf
module "git-clone" {
  source   = "registry.coder.com/modules/git-clone/coder"
  version  = "1.0.2"
  agent_id = coder_agent.example.id
  url      = "https://github.com/coder/coder"
}
```

To use with [Git Authentication](https://coder.com/docs/v2/latest/admin/git-providers), add the provider by ID to your template:

```tf
data "coder_git_auth" "github" {
  id = "github"
}
```

## Examples

### Custom Path

```tf
module "git-clone" {
  source   = "registry.coder.com/modules/git-clone/coder"
  version  = "1.0.2"
  agent_id = coder_agent.example.id
  url      = "https://github.com/coder/coder"
  base_dir = "~/projects/coder"
}
```
