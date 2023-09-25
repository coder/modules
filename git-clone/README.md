---
display_name: Git Clone
description: Clone a Git repository by URL and skip if it exists.
icon: ../.icons/git.svg
maintainer_github: coder
verified: true
tags: [git, helper]
---
# Git Clone

This module allows you to automatically clone a repository by URL and skip if it
exists in the path provided.

## Examples

1. Add only GPU zones in the US West 1 region:

    ```hcl
    module "gcp_region" {
      source   = "https://registry.coder.com/modules/gcp-region"
      default  = ["us-west1-a"]
      regions  = ["us-west1"]
      gpu_only = false
    }
    ```

2. Add all zones in the Europe West region:

    ```hcl
    module "gcp_region" {
      source                 = "https://registry.coder.com/modules/gcp-region"
      regions                = ["europe-west"]
      single_zone_per_region = false
    }
    ```

3. Add a single zone from each region in US and Europe that laos has GPUs

    ```hcl
    module "gcp_region" {
      source                 = "https://registry.coder.com/modules/gcp-region"
      regions                = ["us", "europe"]
      gpu_only               = true
      single_zone_per_region = true
    }
    ```
