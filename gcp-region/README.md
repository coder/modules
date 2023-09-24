---
display_name: GCP Regions
description: Add Google Cloud Platform regions to your Coder template.
icon: ../.icons/gcp.svg
maintainer_github: coder
verified: true
tags: [gcp, regions, zones, helper]
---
# Google Cloud Platform Regions

This module adds Google Cloud Platform regions to your Coder template.

![GCP Regions](../.images/gcp-regions.png)

## Examples

1. Add only GPU zones in the US West 1 region:

    ```hcl
    module "gcp_regions" {
      source   = "git::https://github.com/coder/modules.git//gcp-region?branch=gcp-region"
      default  = ["us-west1-a"]
      regions  = ["us-west1"]
      gpu_only = false
    }
    ```

2. Add all zones in the Europe West region:

    ```hcl
    module "regions" {
      source                 = "https://registry.coder.com/modules/gcp-regions"
      regions                = ["europe-west"]
      single_zone_per_region = false
    }
    ```

3. Add a single zone from each region in US and Europe that laos has GPUs

    ```hcl
    module "regions" {
      source                 = "https://registry.coder.com/modules/gcp-regions"
      regions                = ["us", "europe"]
      gpu_only               = true
      single_zone_per_region = true
    }
    ```
