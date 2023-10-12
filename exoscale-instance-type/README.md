---
display_name: exoscale-instance-type
description: A parameter with human readable exoscale instance names
icon: ../.icons/exoscale.svg
maintainer_github: WhizUs
verified: false
tags: [helper, parameter, instances, exoscale]
---

# exoscale-instance-type

A parameter with all Exoscale instance types. This allows developers to select
their desired virtuell machine for the workspace.

Customize the preselected parameter value:

```hcl
module "exoscale-instance-type" {
    source = "https://registry.coder.com/modules/exoscale-instance-type"
    default = "standard.medium"
    
}

provider "aws" {
    region = module.aws_region.value
}
```

![AWS Regions](../.images/exoscale-instance-types.png)

## Examples

### Customize regions

Change the display name and icon for a region using the corresponding maps:

```hcl
module "exoscale-instance-type" {
    source = "https://registry.coder.com/modules/exoscale-instance-type"
    default = "ap-south-1"
    custom_names = {
        "ap-south-1": "Awesome Mumbai!"
    }
    custom_icons = {
        "ap-south-1": "/emojis/1f33a.png"
    }
}

provider "aws" {
    region = module.aws_region.value
}
```

![AWS Custom](../.images/exoscale-instance-custom.png)

### Exclude regions

Hide the Asia Pacific regions Seoul and Osaka:

```hcl
module "exoscale-instance-type" {
    source = "https://registry.coder.com/modules/exoscale-instance-type"
    exclude = [ "ap-northeast-2", "ap-northeast-3" ]
}

provider "aws" {
    region = module.aws_region.value
}
```

![AWS Exclude](../.images/exoscale-instance-exclude.png)

## Related templates

A related exoscale template will be provided soon.