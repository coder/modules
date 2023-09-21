---
display_name: Azure Region
description: A parameter with human region names and icons
icon: ../.icons/azure.svg
maintainer_github: coder
verified: true
tags: [helper, parameter, azure]
---

# Azure Region

This module adds a parameter with all Azure regions. This allows developers to select the region closest to them.

## Examples

### Default region

```hcl
module "azure_region" {
    source = "https://registry.coder.com/modules/azure-region"
    default = "eastus"
}

provider "azure" {
    region = module.azure_region.value
    ...
}
```

### Customize existing regions

Change the display name for a region:

```hcl
module "azure-region" {
    source = "https://registry.coder.com/modules/azure-region"
    custom_names = {
        "eastus": "Eastern United States!"
    }
    custom_icons = {
        "eastus": "/icons/smiley.svg"
    }
}

provider "azure" {
    region = module.azure_region.value
}
```

### Exclude Regions

Hide the `westus2` region:

```hcl
module "azure-region" {
    source = "https://registry.coder.com/modules/azure-region"
    exclude = [ "westus2" ]
}

provider "azure" {
    region = module.azure_region.value
}
```