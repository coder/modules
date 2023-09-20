---
display_name: AWS Regions
description: Add Amazon Web Services regions to your Coder template.
icon: ../.icons/aws.svg
maintainer_github: coder
verified: true
tags: [aws, regions, zones]
---
# Amazon Web Services Regions

This module adds Amazon Web Services regions to your Coder template.

## How to use this module

To use this module, add the following snippet to your template manifest:

```hcl
module "aws_regions" {
  source      = "https://registry.coder.com/modules/aws-regions"
  gcp_regions = ["us-west-1", "us-west-2"] # Add your desired regions here, use ["all"] for all regions
}
```
