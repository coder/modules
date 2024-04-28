---
display_name: Github Upload Public Key
description: Automates uploading Coder public key to Github so users don't have to.
icon: ../.icons/github.svg
maintainer_github: f0ssel
verified: false
tags: [helper]
---

# github-upload-public-key

<!-- Describes what this module does -->

```tf
module "github-upload-public-key" {
  source   = "registry.coder.com/modules/github-upload-public-key/coder"
  version  = "1.0.13"
  agent_id = coder_agent.example.id
}
```

<!-- Add a screencast or screenshot here  put them in .images directory -->
<!-- TODO: Add examples -->
