---
display_name: GCP Regions
description: Add Google Cloud Platform regions to your Coder template.
icon: ../.icons/gcp.svg
maintainer_github: coder
verified: true
tags: [gcp, regions, zones]
---
# Google Cloud Platform Regions

This module adds Google Cloud Platform regions to your Coder template.

## How to use this module

To use this module, add the following snippet to your template manifest:

```hcl
module "gcp_regions" {
  source      = "https://registry.coder.com/modules/gcp-regions"
  gcp_regions = ["us-west1", "us-west2", "us-west3"] # Add your desired regions here, use ["all"] for all regions
  gpu_only    = true  
}
```
