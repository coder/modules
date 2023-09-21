terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.11"
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
		"asia" = {
			name = "Asia"
			icon = "/emojis/1f30f.png"
		}
		"asiapacific" = {
			name = "Asia Pacific"
			icon = "/emojis/1f30f.png"
		}
		"australia" = {
			name = "Australia"
			icon = "/icons/1f1e6-1f1fa.svg"
		}
		"australiacentral" = {
			name = "Australia Central"
			icon = "/icons/1f1e6-1f1fa.svg"
		}
		"australiacentral2" = {
			name = "Australia Central 2"
			icon = "/icons/1f1e6-1f1fa.svg"
		}
		"australiaeast" = {
			name = "Australia (New South Wales)"
			icon = "/emojis/1f1e6-1f1fa.png"
		}
		"australiasoutheast" = {
			name = "Australia Southeast"
			icon = "/icons/1f1e6-1f1fa.svg"
		}
		"brazil" = {
			name = "Brazil"
			icon = "/icons/1f1e7-1f1f7.svg"
		}
		"brazilsouth" = {
			name = "Brazil (Sao Paulo)"
			icon = "/emojis/1f1e7-1f1f7.png"
		}
		"brazilsoutheast" = {
			name = "Brazil Southeast"
			icon = "/icons/1f1e7-1f1f7.svg"
		}
		"brazilus" = {
			name = "Brazil US"
			icon = "/icons/1f1e7-1f1f7.svg"
		}
		"canada" = {
			name = "Canada"
			icon = "/icons/1f1e8-1f1e6.svg"
		}
		"canadacentral" = {
			name = "Canada (Toronto)"
			icon = "/emojis/1f1e8-1f1e6.png"
		}
		"canadaeast" = {
			name = "Canada East"
			icon = "/icons/1f1e8-1f1e6.svg"
		}
		"centralindia" = {
			name = "India (Pune)"
			icon = "/emojis/1f1ee-1f1f3.png"
		}
		"centralus" = {
			name = "US (Iowa)"
			icon = "/emojis/1f1fa-1f1f8.png"
		}
		"eastasia" = {
			name = "East Asia (Hong Kong)"
			icon = "/emojis/1f1f0-1f1f7.png"
		}
		"eastus" = {
			name = "US (Virginia)"
			icon = "/emojis/1f1fa-1f1f8.png"
		}
		"eastus2" = {
			name = "US (Virginia) 2"
			icon = "/emojis/1f1fa-1f1f8.png"
		}
		"europe" = {
			name = "Europe"
			icon = "/emojis/1f30d.png"
		}
		"france" = {
			name = "France"
			icon = "/icons/1f1eb-1f1f7.svg"
		}
		"francecentral" = {
			name = "France (Paris)"
			icon = "/emojis/1f1eb-1f1f7.png"
		}
		"francesouth" = {
			name = "France South"
			icon = "/icons/1f1eb-1f1f7.svg"
		}
		"germany" = {
			name = "Germany"
			icon = "/icons/1f1e9-1f1ea.svg"
		}
		"germanynorth" = {
			name = "Germany North"
			icon = "/icons/1f1e9-1f1ea.svg"
		}
		"germanywestcentral" = {
			name = "Germany (Frankfurt)"
			icon = "/emojis/1f1e9-1f1ea.png"
		}
		"global" = {
			name = "Global"
			icon = "/emojis/1f310.png"
		}
		"india" = {
			name = "India"
			icon = "/icons/1f1ee-1f1f3.svg"
		}
		"japan" = {
			name = "Japan"
			icon = "/icons/1f1ef-1f1f5.svg"
		}
		"japaneast" = {
			name = "Japan (Tokyo)"
			icon = "/emojis/1f1ef-1f1f5.png"
		}
		"japanwest" = {
			name = "Japan West"
			icon = "/icons/1f1ef-1f1f5.svg"
		}
		"jioindiacentral" = {
			name = "Jio India Central"
			icon = "/icons/1f1ee-1f1f3.svg"
		}
		"jioindiawest" = {
			name = "Jio India West"
			icon = "/icons/1f1ee-1f1f3.svg"
		}
		"korea" = {
			name = "Korea"
			icon = "/emojis/1f1f0-1f1f7.png"
		}
		"koreacentral" = {
			name = "Korea (Seoul)"
			icon = "/emojis/1f1f0-1f1f7.png"
		}
		"koreasouth" = {
			name = "Korea South"
			icon = "/emojis/1f1f0-1f1f7.png"
		}
		"northcentralus" = {
			name = "North Central US"
			icon = "/emojis/1f1fa-1f1f8.png"
		}
		"northeurope" = {
			name = "Europe (Ireland)"
			icon = "/emojis/1f1ea-1f1fa.png"
		}
		"norway" = {
			name = "Norway"
			icon = "/icons/1f1f3-1f1f4.svg"
		}
		"norwayeast" = {
			name = "Norway (Oslo)"
			icon = "/emojis/1f1f3-1f1f4.png"
		}
		"norwaywest" = {
			name = "Norway West"
			icon = "/icons/1f1f3-1f1f4.svg"
		}
		"qatarcentral" = {
			name = "Qatar (Doha)"
			icon = "/emojis/1f1f6-1f1e6.png"
		}
		"singapore" = {
			name = "Singapore"
			icon = "/icons/1f1f8-1f1ec.svg"
		}
		"southafrica" = {
			name = "South Africa"
			icon = "/icons/1f1ff-1f1e6.svg"
		}
		"southafricanorth" = {
			name = "South Africa (Johannesburg)"
			icon = "/emojis/1f1ff-1f1e6.png"
		}
		"southafricawest" = {
			name = "South Africa West"
			icon = "/icons/1f1ff-1f1e6.svg"
		}
		"southcentralus" = {
			name = "US (Texas)"
			icon = "/emojis/1f1fa-1f1f8.png"
		}
		"southeastasia" = {
			name = "Southeast Asia (Singapore)"
			icon = "/emojis/1f1f0-1f1f7.png"
		}
		"southindia" = {
			name = "South India"
			icon = "/icons/1f1ee-1f1f3.svg"
		}
		"swedencentral" = {
			name = "Sweden (Gävle)"
			icon = "/emojis/1f1f8-1f1ea.png"
		}
		"switzerland" = {
			name = "Switzerland"
			icon = "/icons/1f1e8-1f1ed.svg"
		}
		"switzerlandnorth" = {
			name = "Switzerland (Zurich)"
			icon = "/emojis/1f1e8-1f1ed.png"
		}
		"switzerlandwest" = {
			name = "Switzerland West"
			icon = "/icons/1f1e8-1f1ed.svg"
		}
		"uae" = {
			name = "United Arab Emirates"
			icon = "/icons/1f1e6-1f1ea.svg"
		}
		"uaecentral" = {
			name = "UAE Central"
			icon = "/icons/1f1e6-1f1ea.svg"
		}
		"uaenorth" = {
			name = "UAE (Dubai)"
			icon = "/emojis/1f1e6-1f1ea.png"
		}
		"uk" = {
			name = "United Kingdom"
			icon = "/emojis/1f1ec-1f1e7.png"
		}
		"uksouth" = {
			name = "UK (London)"
			icon = "/emojis/1f1ec-1f1e7.png"
		}
		"ukwest" = {
			name = "UK West"
			icon = "/emojis/1f1ec-1f1e7.png"
		}
		"unitedstates" = {
			name = "United States"
			icon = "/icons/1f1fa-1f1f8.svg"
		}
		"westcentralus" = {
			name = "West Central US"
			icon = "/emojis/1f1fa-1f1f8.png"
		}
		"westeurope" = {
			name = "Europe (Netherlands)"
			icon = "/emojis/1f1ea-1f1fa.png"
		}
		"westindia" = {
			name = "West India"
			icon = "/icons/1f1ee-1f1f3.svg"
		}
		"westus" = {
			name = "West US"
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
