terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.12"
    }
  }
}

variable "display_name" {
    default = "Azure Region"
    description = "The display name of the Coder parameter."
    type = string
}

variable "description" {
  default = "The region where your workspace will live."
  description = "Description of the Coder parameter."
}

variable "default" {
    default = "eastus"
    description = "The default region to use if no region is specified."
    type = string
}

variable "mutable" {
    default = false
    description = "Whether the parameter can be changed after creation."
    type = bool
}

variable "custom_names" {
    default = {}
    description = "A map of custom display names for region IDs."
    type = map(string)
}

variable "custom_icons" {
    default = {}
    description = "A map of custom icons for region IDs."
    type = map(string)
}

variable "exclude" {
    default = []
    description = "A list of region IDs to exclude."
    type = list(string)
}

locals {
    all_regions = {
        "eastus" = {
            name = "US (Virginia)"
            icon = "/emojis/1f1fa-1f1f8.png"
        }
        "eastus2" = {
            name = "US (Virginia) 2"
            icon = "/emojis/1f1fa-1f1f8.png"
        }
        "southcentralus" = {
            name = "US (Texas)"
            icon = "/emojis/1f1fa-1f1f8.png"
        }
        "westus2" = {
            name = "US (Washington)"
            icon = "/emojis/1f1fa-1f1f8.png"
        }
        "westus3" = {
            name = "US (Arizona)"
            icon = "/emojis/1f1fa-1f1f8.png"
        }
        "centralus" = {
            name = "US (Iowa)"
            icon = "/emojis/1f1fa-1f1f8.png"
        }
        "canadacentral" = {
            name = "Canada (Toronto)"
            icon = "/emojis/1f1e8-1f1e6.png"
        }
        "brazilsouth" = {
        name = "Brazil (Sao Paulo)"
        icon = "/emojis/1f1e7-1f1f7.png"
        }
        "eastasia" = {
        name = "East Asia (Hong Kong)"
        icon = "/emojis/1f1f0-1f1f7.png"
        }
        "southeastasia" = {
        name = "Southeast Asia (Singapore)"
        icon = "/emojis/1f1f0-1f1f7.png"
        }
        "australiaeast" = {
        name = "Australia (New South Wales)"
        icon = "/emojis/1f1e6-1f1fa.png"
        }
        "chinanorth3" = {
        name = "China (Hebei)"
        icon = "/emojis/1f1e8-1f1f3.png"
        }
        "centralindia" = {
        name = "India (Pune)"
        icon = "/emojis/1f1ee-1f1f3.png"
        }
        "japaneast" = {
        name = "Japan (Tokyo)"
        icon = "/emojis/1f1ef-1f1f5.png"
        }
        "koreacentral" = {
        name = "Korea (Seoul)"
        icon = "/emojis/1f1f0-1f1f7.png"
        }
        "northeurope" = {
        name = "Europe (Ireland)"
        icon = "/emojis/1f1ea-1f1fa.png"
        }
        "westeurope" = {
        name = "Europe (Netherlands)"
        icon = "/emojis/1f1ea-1f1fa.png"
        }
        "francecentral" = {
        name = "France (Paris)"
        icon = "/emojis/1f1eb-1f1f7.png"
        }
        "germanywestcentral" = {
        name = "Germany (Frankfurt)"
        icon = "/emojis/1f1e9-1f1ea.png"
        }
        "norwayeast" = {
        name = "Norway (Oslo)"
        icon = "/emojis/1f1f3-1f1f4.png"
        }
        "swedencentral" = {
        name = "Sweden (Gävle)"
        icon = "/emojis/1f1f8-1f1ea.png"
        }
        "switzerlandnorth" = {
        name = "Switzerland (Zurich)"
        icon = "/emojis/1f1e8-1f1ed.png"
        }
        "qatarcentral" = {
        name = "Qatar (Doha)"
        icon = "/emojis/1f1f6-1f1e6.png"
        }
        "uaenorth" = {
        name = "UAE (Dubai)"
        icon = "/emojis/1f1e6-1f1ea.png"
        }
        "southafricanorth" = {
        name = "South Africa (Johannesburg)"
        icon = "/emojis/1f1ff-1f1e6.png"
        }
        "uksouth" = {
        name = "UK (London)"
        icon = "/emojis/1f1ec-1f1e7.png"
        }
    }
}

data "coder_parameter" "region" {
    name = "azure_region"
    display_name = var.display_name
    description = var.description
    default = var.default
    mutable = var.mutable
    dynamic "option" {
        for_each = { for k, v in local.all_regions : k => v if !(contains(var.exclude, k)) }
        content {
            name = try(var.custom_names[option.key], option.value.name)
            icon = try(var.custom_icons[option.key], option.value.icon)
            value = option.key
        }
    }
}

output "value" {
    value = data.coder_parameter.region.value
}
