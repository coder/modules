---
display_name: Coder Login
description: Automatically logs the user into Coder on their workspace
icon: ../.icons/coder-white.svg
maintainer_github: coder
verified: true
tags: [helper]
---

# Coder Login

Automatically logs the user into Coder when creating their workspace.

```hcl
module "coder-login" {
    agent_id = coder_agent.example.id
}
```

![Coder Login Logs](../.images/coder-login.png)
