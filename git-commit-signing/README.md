---
display_name: Git commit signing
description: Configures Git to sign commits using your Coder SSH key
icon:  ../.icons/git.svg
maintainer_github: phorcys420
verified: false
tags: [helper, git]
---

# git-commit-signing

This module downloads your SSH key from Coder and uses it to sign commits with Git.
It requires `jq` to be installed inside your workspace.

This is not recommended if your workspace can be accessed by other/unwanted people, in the case an administrator account on your Coder account gets breached, the attacker could gain access to your workspace and sign commits on your behalf (since the key is stored in the worksace).
If your Coder account gets breached, the SSH key could also be used on your behalf.

```hcl
module "git-commit-signing" {
    source = "https://registry.coder.com/modules/git-commit-signing"
    agent_id = coder_agent.example.id
}
```
