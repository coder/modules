---
display_name: Git Config
description: Stores Git configuration from Coder credentials
icon: ../.icons/git.svg
maintainer_github: coder
verified: true
tags: [helper, git]
---

# git-config

Runs a script that checks for stored Git credentials `user.name` and `user.email`, populating them with workspace owner's credentials when missing. 


## Examples

### Using Workspace owner
The credentials can be populated from the workspace owner's information.

```hcl
module "git-config" {
  source = "git::https://github.com/coder/modules.git//git-config?ref=git-config"
  agent_id = coder_agent.main.id
  username = data.coder_workspace.me.owner
  user_email = data.coder_workspace.me.owner_email
}
```

### Custom credentials
Credentials can also be set manually.

```hcl
module "git-config" {
  source = "git::https://github.com/coder/modules.git//git-config?ref=git-config"
  agent_id = coder_agent.main.id
  username = "michael"
  user_email = "michael@example.com"
}
```

