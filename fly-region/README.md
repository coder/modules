---
display_name: Fly.io Region
description: A parameter with human region names and icons
icon: ../.icons/fly.svg
maintainer_github: coder
verified: true
tags: [helper, parameter, fly]
---

# Fly.io Region

This module adds Fly.io regions to your Coder template. Regions can be whitelisted using the `regions` argument and given custom names and custom icons with their respective map arguments (`custom_names`, `custom_icons`). 

## Examples

### Using default settings

```hcl
module "fly-region" {
    source = "https://registry.coder.com/modules/fly-region"
}
```

[]()


### Using region whitelist

The regions argument can be used to display only the desired regions in the Coder parameter.

```hcl
module "fly-region" {
    source = "https://registry.coder.com/modules/fly-region"
    default = "ams"
    regions = ["ams", "arn", "atl"]
}
```

 TODO: Add screenshot filtered_flyio.png


### Using custom icons and names

Set custom icons and names with their respective maps.

```hcl
module "fly-region" {
    source = "https://registry.coder.com/modules/fly-region"
    default = "ams"
    custom_icons = {
        "ams" = "/emojis/1f90e.png"
    }
    custom_names = {
        "ams" = "We love the Netherlands!"
    }
}
```