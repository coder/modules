---
display_name: AWS Region
description: A parameter with human region names and icons
icon: ../.icons/aws.svg
maintainer_github: coder
verified: true
tags: [helper, parameter, regions, aws]
---

# AWS Region

A parameter with all AWS regions. This allows developers to select
the region closest to them.

![AWS Regions](../.images/aws-region.png)

Customize the preselected parameter value:

```hcl
module "aws-region" {
    source = "https://registry.coder.com/modules/aws-region"
    default = "us-east-1"
}

provider "aws" {
    region = module.aws_region.value
}
```

## Examples

### Customize Regions

Change the display name and icon for a region:

```hcl
module "aws-region" {
    source = "https://registry.coder.com/modules/aws-region"
    custom_names = {
        "fra": "Awesome Germany!"
    }
    custom_icons = {
        "fra": "/icons/smiley.svg"
    }
}

provider "aws" {
    region = module.aws_region.value
}
```

### Exclude Regions

Hide the `fra` region:

```hcl
module "aws-region" {
    source = "https://registry.coder.com/modules/aws-region"
    exclude = [ "fra" ]
}

provider "aws" {
    region = module.aws_region.value
}
```
