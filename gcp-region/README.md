---
display_name: GCP Regions
description: Add Google Cloud Platform regions to your Coder template.
icon: ../.icons/gcp.svg
maintainer_github: coder
verified: true
tags: [gcp, regions, helper]
---
# Google Cloud Platform Regions

This module adds Google Cloud Platform regions to your Coder template.

## Examples

1. Add only GPU zones in the US West 1 region:

    ```hcl
    module "regions" {
      source      = "https://registry.coder.com/modules/gcp-regions"
      default     = ["us-west1"]
      gpu_only    = true
    }
    ```

2. Add all zones in the Europe West region:

    ```hcl
    module "regions" {
      source      = "https://registry.coder.com/modules/gcp-regions"
      default     = ["europe-west"]
    }
    ```
