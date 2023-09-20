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
  default     = "GCP Region"
  description = "The display name of the parameter."
  type        = string
}

variable "description" {
  default     = "The region to deploy workspace infrastructure."
  description = "The description of the parameter."
  type        = string
}

variable "default" {
  description = "List of GCP regions to include."
  type        = list(string)
  default     = ["us-central1"]
}

variable "gpu_only" {
  description = "Whether to only include zones with GPUs."
  type        = bool
  default     = false
}

variable "mutable" {
  default     = false
  description = "Whether the parameter can be changed after creation."
  type        = bool
}

variable "custom_names" {
  default     = {}
  description = "A map of custom display names for region IDs."
  type        = map(string)
}

variable "custom_icons" {
  default     = {}
  description = "A map of custom icons for region IDs."
  type        = map(string)
}

locals {
  zones = {
    # US Central
    "us-central1-a" = {
      has_gpu = true
      name    = "Council Bluffs, Iowa, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }
    "us-central1-b" = {
      has_gpu = true
      name    = "Council Bluffs, Iowa, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }
    "us-central1-c" = {
      has_gpu = true
      name    = "Council Bluffs, Iowa, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }
    "us-central1-f" = {
      has_gpu = true
      name    = "Council Bluffs, Iowa, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }

    # US East
    "us-east1-b" = {
      has_gpu = true
      name    = "Moncks Corner, S. Carolina, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }
    "us-east1-c" = {
      has_gpu = true
      name    = "Moncks Corner, S. Carolina, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }
    "us-east1-d" = {
      has_gpu = true
      name    = "Moncks Corner, S. Carolina, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }

    "us-east4-a" = {
      has_gpu = true
      name    = "Ashburn, Virginia, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }
    "us-east4-b" = {
      has_gpu = true
      name    = "Ashburn, Virginia, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }
    "us-east4-c" = {
      has_gpu = true
      name    = "Ashburn, Virginia, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }

    "us-east5-a" = {
      has_gpu = false
      name    = "Columbus, Ohio, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }
    "us-east5-b" = {
      has_gpu = true
      name    = "Columbus, Ohio, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }
    "us-east5-c" = {
      has_gpu = false
      name    = "Columbus, Ohio, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }

    # Us West
    "us-west1-a" = {
      has_gpu = true
      name    = "The Dalles, Oregon, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }
    "us-west1-b" = {
      has_gpu = true
      name    = "The Dalles, Oregon, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }
    "us-west1-c" = {
      has_gpu = false
      name    = "The Dalles, Oregon, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }

    "us-west2-a" = {
      has_gpu = false
      name    = "Los Angeles, California, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }
    "us-west2-b" = {
      has_gpu = true
      name    = "Los Angeles, California, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }
    "us-west2-c" = {
      has_gpu = true
      name    = "Los Angeles, California, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }

    "us-west3-a" = {
      has_gpu = true
      name    = "Salt Lake City, Utah, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }
    "us-west3-b" = {
      has_gpu = true
      name    = "Salt Lake City, Utah, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }
    "us-west3-c" = {
      has_gpu = true
      name    = "Salt Lake City, Utah, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }

    "us-west4-a" = {
      has_gpu = true
      name    = "Las Vegas, Nevada, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }
    "us-west4-b" = {
      has_gpu = true
      name    = "Las Vegas, Nevada, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }
    "us-west4-c" = {
      has_gpu = true
      name    = "Las Vegas, Nevada, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }

    # US South
    "us-south1-a" = {
      has_gpu = false
      name    = "Dallas, Texas, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }
    "us-south1-b" = {
      has_gpu = false
      name    = "Dallas, Texas, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }
    "us-south1-c" = {
      has_gpu = false
      name    = "Dallas, Texas, USA"
      icon    = "/emojis/1f1fa-1f1f8.png"
    }

    # Canada
    "northamerica-northeast1-a" = {
      has_gpu = true
      name    = "Montréal, Québec, Canada"
      icon    = "/emojis/1f1e8-1f1f6.png"
    }
    "northamerica-northeast1-b" = {
      has_gpu = true
      name    = "Montréal, Québec, Canada"
      icon    = "/emojis/1f1e8-1f1f6.png"
    }
    "northamerica-northeast1-c" = {
      has_gpu = true
      name    = "Montréal, Québec, Canada"
      icon    = "/emojis/1f1e8-1f1f6.png"
    }

    "northamerica-northeast2-a" = {
      has_gpu = false
      name    = "Toronto, Ontario, Canada"
      icon    = "/emojis/1f1e8-1f1f6.png"
    }
    "northamerica-northeast2-b" = {
      has_gpu = false
      name    = "Toronto, Ontario, Canada"
      icon    = "/emojis/1f1e8-1f1f6.png"
    }
    "northamerica-northeast2-c" = {
      has_gpu = false
      name    = "Toronto, Ontario, Canada"
      icon    = "/emojis/1f1e8-1f1f6.png"
    }

    # South America East (Brazil, Chile)
    "southamerica-east1-a" = {
      has_gpu = true
      name    = "Osasco, São Paulo, Brazil"
      icon    = "/emojis/1f1e7-1f1f7.png"
    }
    "southamerica-east1-b" = {
      has_gpu = false
      name    = "Osasco, São Paulo, Brazil"
      icon    = "/emojis/1f1e7-1f1f7.png"
    }
    "southamerica-east1-c" = {
      has_gpu = true
      name    = "Osasco, São Paulo, Brazil"
      icon    = "/emojis/1f1e7-1f1f7.png"
    }

    "southamerica-west1-a" = {
      has_gpu = false
      name    = "Santiago, Chile"
      icon    = "/emojis/1f1e8-1f1f1.png"
    }
    "southamerica-west1-b" = {
      has_gpu = false
      name    = "Santiago, Chile"
      icon    = "/emojis/1f1e8-1f1f1.png"
    }
    "southamerica-west1-c" = {
      has_gpu = false
      name    = "Santiago, Chile"
      icon    = "/emojis/1f1e8-1f1f1.png"
    }

    # Europe North (Finland)
    "europe-north1-a" = {
      has_gpu = false
      name    = "Hamina, Finland"
      icon    = "/emojis/1f1e7-1f1ee.png"
    }
    "europe-north1-b" = {
      has_gpu = false
      name    = "Hamina, Finland"
      icon    = "/emojis/1f1e7-1f1ee.png"
    }
    "europe-north1-c" = {
      has_gpu = false
      name    = "Hamina, Finland"
      icon    = "/emojis/1f1e7-1f1ee.png"
    }

    # Europe Central (Poland)
    "europe-central2-a" = {
      has_gpu = false
      name    = "Warsaw, Poland"
      icon    = "/emojis/1f1f5-1f1f1.png"
    }
    "europe-central2-b" = {
      has_gpu = true
      name    = "Warsaw, Poland"
      icon    = "/emojis/1f1f5-1f1f1.png"
    }
    "europe-central2-c" = {
      has_gpu = true
      name    = "Warsaw, Poland"
      icon    = "/emojis/1f1f5-1f1f1.png"
    }

    # Europe Southwest (Spain)
    "europe-southwest1-a" = {
      has_gpu = false
      name    = "Madrid, Spain"
      icon    = "/emojis/1f1ea-1f1f8.png"
    }
    "europe-southwest1-b" = {
      has_gpu = false
      name    = "Madrid, Spain"
      icon    = "/emojis/1f1ea-1f1f8.png"
    }
    "europe-southwest1-c" = {
      has_gpu = false
      name    = "Madrid, Spain"
      icon    = "/emojis/1f1ea-1f1f8.png"
    }

    # Europe West
    "europe-west1-b" = {
      has_gpu = true
      name    = "St. Ghislain, Belgium"
      icon    = "/emojis/1f1e7-1f1ea.png"
    }
    "europe-west1-c" = {
      has_gpu = true
      name    = "St. Ghislain, Belgium"
      icon    = "/emojis/1f1e7-1f1ea.png"
    }
    "europe-west1-d" = {
      has_gpu = true
      name    = "St. Ghislain, Belgium"
      icon    = "/emojis/1f1e7-1f1ea.png"
    }

    "europe-west2-a" = {
      has_gpu = true
      name    = "London, England"
      icon    = "/emojis/1f173-1f1ff.png"
    }
    "europe-west2-b" = {
      has_gpu = true
      name    = "London, England"
      icon    = "/emojis/1f173-1f1ff.png"
    }
    "europe-west2-c" = {
      has_gpu = false
      name    = "London, England"
      icon    = "/emojis/1f173-1f1ff.png"
    }

    "europe-west3-b" = {
      has_gpu = false
      name    = "Frankfurt, Germany"
      icon    = "/emojis/1f1e9-1f1ea.png"
    }
    "europe-west3-c" = {
      has_gpu = true
      name    = "Frankfurt, Germany"
      icon    = "/emojis/1f1e9-1f1ea.png"
    }
    "europe-west3-d" = {
      has_gpu = false
      name    = "Frankfurt, Germany"
      icon    = "/emojis/1f1e9-1f1ea.png"
    }

    "europe-west4-a" = {
      has_gpu = true
      name    = "Eemshaven, Netherlands"
      icon    = "/emojis/1f1f3-1f1f1.png"
    }
    "europe-west4-b" = {
      has_gpu = true
      name    = "Eemshaven, Netherlands"
      icon    = "/emojis/1f1f3-1f1f1.png"
    }
    "europe-west4-c" = {
      has_gpu = true
      name    = "Eemshaven, Netherlands"
      icon    = "/emojis/1f1f3-1f1f1.png"
    }

    "europe-west6-a" = {
      has_gpu = false
      name    = "Zurich, Switzerland"
      icon    = "/emojis/1f1e8-1f1ed.png"
    }
    "europe-west6-b" = {
      has_gpu = false
      name    = "Zurich, Switzerland"
      icon    = "/emojis/1f1e8-1f1ed.png"
    }
    "europe-west6-c" = {
      has_gpu = false
      name    = "Zurich, Switzerland"
      icon    = "/emojis/1f1e8-1f1ed.png"
    }

    "europe-west8-a" = {
      has_gpu = false
      name    = "Milan, Italy"
      icon    = "/emojis/1f1ee-1f1f9.png"
    }
    "europe-west8-b" = {
      has_gpu = false
      name    = "Milan, Italy"
      icon    = "/emojis/1f1ee-1f1f9.png"
    }
    "europe-west8-c" = {
      has_gpu = false
      name    = "Milan, Italy"
      icon    = "/emojis/1f1ee-1f1f9.png"
    }

    "europe-west9-a" = {
      has_gpu = false
      name    = "Paris, France"
      icon    = "/emojis/1f1eb-1f1f7.png"
    }
    "europe-west9-b" = {
      has_gpu = false
      name    = "Paris, France"
      icon    = "/emojis/1f1eb-1f1f7.png"
    }
    "europe-west9-c" = {
      has_gpu = false
      name    = "Paris, France"
      icon    = "/emojis/1f1eb-1f1f7.png"
    }

    "europe-west10-a" = {
      has_gpu = false
      name    = "Berlin, Germany"
      icon    = "/emojis/1f1e9-1f1ea.png"
    }
    "europe-west10-b" = {
      has_gpu = false
      name    = "Berlin, Germany"
      icon    = "/emojis/1f1e9-1f1ea.png"
    }
    "europe-west10-c" = {
      has_gpu = false
      name    = "Berlin, Germany"
      icon    = "/emojis/1f1e9-1f1ea.png"
    }

    "europe-west12-a" = {
      has_gpu = false
      name    = "Turin, Italy"
      icon    = "/emojis/1f1ee-1f1f9.png"
    }
    "europe-west12-b" = {
      has_gpu = false
      name    = "Turin, Italy"
      icon    = "/emojis/1f1ee-1f1f9.png"
    }
    "europe-west12-c" = {
      has_gpu = false
      name    = "Turin, Italy"
      icon    = "/emojis/1f1ee-1f1f9.png"
    }

    # Middleeast Central (Qatar, Saudi Arabia)
    "me-central1-a" = {
      has_gpu = false
      name    = "Doha, Qatar"
      icon    = "/emojis/1f1f6-1f1e6.png"
    }
    "me-central1-b" = {
      has_gpu = false
      name    = "Doha, Qatar"
      icon    = "/emojis/1f1f6-1f1e6.png"
    }
    "me-central1-c" = {
      has_gpu = false
      name    = "Doha, Qatar"
      icon    = "/emojis/1f1f6-1f1e6.png"
    }

    "me-central2-a" = {
      has_gpu = false
      name    = "Dammam, Saudi Arabia"
      icon    = "/emojis/1f1f8-1f1e6.png"
    }
    "me-central2-b" = {
      has_gpu = false
      name    = "Dammam, Saudi Arabia"
      icon    = "/emojis/1f1f8-1f1e6.png"
    }
    "me-central2-c" = {
      has_gpu = false
      name    = "Dammam, Saudi Arabia"
      icon    = "/emojis/1f1f8-1f1e6.png"
    }

    # Middleeast West (Israel)
    "me-west1-a" = {
      has_gpu = false
      name    = "Tel Aviv, Israel"
      icon    = "/emojis/1f1ee-1f1f1.png"
    }
    "me-west1-b" = {
      has_gpu = true
      name    = "Tel Aviv, Israel"
      icon    = "/emojis/1f1ee-1f1f1.png"
    }
    "me-west1-c" = {
      has_gpu = true
      name    = "Tel Aviv, Israel"
      icon    = "/emojis/1f1ee-1f1f1.png"
    }

    # Asia East (Taiwan, Hong Kong)
    "asia-east1-a" = {
      has_gpu = true
      name    = "Changhua County, Taiwan"
      icon    = "/emojis/1f1f9-1f1fc.png"
    }
    "asia-east1-b" = {
      has_gpu = true
      name    = "Changhua County, Taiwan"
      icon    = "/emojis/1f1f9-1f1fc.png"
    }
    "asia-east1-c" = {
      has_gpu = true
      name    = "Changhua County, Taiwan"
      icon    = "/emojis/1f1f9-1f1fc.png"
    }

    "asia-east2-a" = {
      has_gpu = true
      name    = "Hong Kong"
      icon    = "/emojis/1f1ed-1f1f0.png"
    }
    "asia-east2-b" = {
      has_gpu = false
      name    = "Hong Kong"
      icon    = "/emojis/1f1ed-1f1f0.png"
    }
    "asia-east2-c" = {
      has_gpu = true
      name    = "Hong Kong"
      icon    = "/emojis/1f1ed-1f1f0.png"
    }

    # Asia Northeast (Japan, South Korea)
    "asia-northeast1-a" = {
      has_gpu = true
      name    = "Tokyo, Japan"
      icon    = "/emojis/1f1ef-1f1f5.png"
    }
    "asia-northeast1-b" = {
      has_gpu = false
      name    = "Tokyo, Japan"
      icon    = "/emojis/1f1ef-1f1f5.png"
    }
    "asia-northeast1-c" = {
      has_gpu = true
      name    = "Tokyo, Japan"
      icon    = "/emojis/1f1ef-1f1f5.png"
    }
    "asia-northeast2-a" = {
      has_gpu = false
      name    = "Osaka, Japan"
      icon    = "/emojis/1f1ef-1f1f5.png"
    }
    "asia-northeast2-b" = {
      has_gpu = false
      name    = "Osaka, Japan"
      icon    = "/emojis/1f1ef-1f1f5.png"
    }
    "asia-northeast2-c" = {
      has_gpu = false
      name    = "Osaka, Japan"
      icon    = "/emojis/1f1ef-1f1f5.png"
    }
    "asia-northeast3-a" = {
      has_gpu = true
      name    = "Seoul, South Korea"
      icon    = "/emojis/1f1f0-1f1f7.png"
    }
    "asia-northeast3-b" = {
      has_gpu = true
      name    = "Seoul, South Korea"
      icon    = "/emojis/1f1f0-1f1f7.png"
    }
    "asia-northeast3-c" = {
      has_gpu = true
      name    = "Seoul, South Korea"
      icon    = "/emojis/1f1f0-1f1f7.png"
    }

    # Asia South (India)
    "asia-south1-a" = {
      has_gpu = true
      name    = "Mumbai, India"
      icon    = "/emojis/1f1ee-1f1f3.png"
    }
    "asia-south1-b" = {
      has_gpu = true
      name    = "Mumbai, India"
      icon    = "/emojis/1f1ee-1f1f3.png"
    }
    "asia-south1-c" = {
      has_gpu = false
      name    = "Mumbai, India"
      icon    = "/emojis/1f1ee-1f1f3.png"
    }
    "asia-south2-a" = {
      has_gpu = false
      name    = "Delhi, India"
      icon    = "/emojis/1f1ee-1f1f3.png"
    }
    "asia-south2-b" = {
      has_gpu = false
      name    = "Delhi, India"
      icon    = "/emojis/1f1ee-1f1f3.png"
    }
    "asia-south2-c" = {
      has_gpu = false
      name    = "Delhi, India"
      icon    = "/emojis/1f1ee-1f1f3.png"
    }

    # Asia Southeast (Singapore, Indonesia)
    "asia-southeast1-a" = {
      has_gpu = true
      name    = "Jurong West, Singapore"
      icon    = "/emojis/1f1f8-1f1ec.png"
    }
    "asia-southeast1-b" = {
      has_gpu = true
      name    = "Jurong West, Singapore"
      icon    = "/emojis/1f1f8-1f1ec.png"
    }
    "asia-southeast1-c" = {
      has_gpu = true
      name    = "Jurong West, Singapore"
      icon    = "/emojis/1f1f8-1f1ec.png"
    }
    "asia-southeast2-a" = {
      has_gpu = true
      name    = "Jakarta, Indonesia"
      icon    = "/emojis/1f1ee-1f1e9.png"
    }
    "asia-southeast2-b" = {
      has_gpu = true
      name    = "Jakarta, Indonesia"
      icon    = "/emojis/1f1ee-1f1e9.png"
    }
    "asia-southeast2-c" = {
      has_gpu = true
      name    = "Jakarta, Indonesia"
      icon    = "/emojis/1f1ee-1f1e9.png"
    }

    # Australia (Sydney, Melbourne)
    "australia-southeast1-a" = {
      has_gpu = true
      name    = "Sydney, Australia"
      icon    = "/emojis/1f1e6-1f1fa.png"
    }
    "australia-southeast1-b" = {
      has_gpu = true
      name    = "Sydney, Australia"
      icon    = "/emojis/1f1e6-1f1fa.png"
    }
    "australia-southeast1-c" = {
      has_gpu = true
      name    = "Sydney, Australia"
      icon    = "/emojis/1f1e6-1f1fa.png"
    }
    "australia-southeast2-a" = {
      has_gpu = false
      name    = "Melbourne, Australia"
      icon    = "/emojis/1f1e6-1f1fa.png"
    }
    "australia-southeast2-b" = {
      has_gpu = false
      name    = "Melbourne, Australia"
      icon    = "/emojis/1f1e6-1f1fa.png"
    }
    "australia-southeast2-c" = {
      has_gpu = false
      name    = "Melbourne, Australia"
      icon    = "/emojis/1f1e6-1f1fa.png"
    }
  }
}

data "coder_parameter" "region" {
  name         = "gcp_region"
  display_name = var.display_name
  description  = var.description
  icon         = "/icon/gcp.svg"
  mutable      = var.mutable
  dynamic "option" {
    for_each = { for k, v in local.zones : k => v if(contains(var.default, k) || contains(var.default, "all")) && (!var.gpu_only || v.has_gpu) }
    content {
      icon        = try(var.custom_icons[option.key], option.value.icon)
      name        = try(var.custom_names[option.key], option.value.name)
      description = option.key
      value       = option.key
    }
  }
}

output "value" {
  value = data.coder_parameter.region.value
}
