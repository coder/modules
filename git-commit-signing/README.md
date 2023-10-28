---
display_name: Git commit signing
description: Configures Git to sign commits using your Coder SSH key
icon: ../.icons/git.svg
maintainer_github: phorcys420
verified: false
tags: [helper, git]
---

# git-commit-signing

This module downloads your SSH key from Coder and uses it to sign commits with Git.
It requires `curl` and `jq` to be installed inside your workspace.

Please observe that using the SSH key that's part of your Coder account for commit signing, means that in the event of a breach of your Coder account, or a malicious admin, someone could perform commit signing pretending to be you.

```hcl
module "git-commit-signing" {
    source = "https://registry.coder.com/modules/git-commit-signing"
    agent_id = coder_agent.example.id
}
```
