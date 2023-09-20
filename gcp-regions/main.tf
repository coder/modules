terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.11"
    }
  }
}

variable "gcp_regions" {
  description = "List of GCP regions to include."
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.gcp_regions) > 0
    error_message = "At least one region must be selected."
  }
  validation {
    condition     = can(regexall("^[a-z0-9-]+$", var.gcp_regions))
    error_message = "All regions must be valid names."
  }
}

variable "gpu_only" {
  description = "Whether to only include zones with GPUs."
  type        = bool
  default     = false
}

locals {
  all_zones = [
    # US Central
    { zone = "us-central1-a", has_gpu = true, location = "Council Bluffs, Iowa, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-central1-b", has_gpu = true, location = "Council Bluffs, Iowa, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-central1-c", has_gpu = true, location = "Council Bluffs, Iowa, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-central1-f", has_gpu = true, location = "Council Bluffs, Iowa, USA", icon = "/emojis/1f1fa-1f1f8.png" },

    # US East
    { zone = "us-east1-b", has_gpu = true, location = "Moncks Corner, S. Carolina, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-east1-c", has_gpu = true, location = "Moncks Corner, S. Carolina, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-east1-d", has_gpu = true, location = "Moncks Corner, S. Carolina, USA", icon = "/emojis/1f1fa-1f1f8.png" },

    { zone = "us-east4-a", has_gpu = true, location = "Ashburn, Virginia, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-east4-b", has_gpu = true, location = "Ashburn, Virginia, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-east4-c", has_gpu = true, location = "Ashburn, Virginia, USA", icon = "/emojis/1f1fa-1f1f8.png" },

    { zone = "us-east5-a", has_gpu = false, location = "Columbus, Ohio, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-east5-b", has_gpu = true, location = "Columbus, Ohio, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-east5-c", has_gpu = false, location = "Columbus, Ohio, USA", icon = "/emojis/1f1fa-1f1f8.png" },

    # Us West
    { zone = "us-west1-a", has_gpu = true, location = "The Dalles, Oregon, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-west1-b", has_gpu = true, location = "The Dalles, Oregon, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-west1-c", has_gpu = false, location = "The Dalles, Oregon, USA", icon = "/emojis/1f1fa-1f1f8.png" },

    { zone = "us-west2-a", has_gpu = false, location = "Los Angeles, California, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-west2-b", has_gpu = true, location = "Los Angeles, California, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-west2-c", has_gpu = true, location = "Los Angeles, California, USA", icon = "/emojis/1f1fa-1f1f8.png" },

    { zone = "us-west3-a", has_gpu = true, location = "Salt Lake City, Utah, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-west3-b", has_gpu = true, location = "Salt Lake City, Utah, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-west3-c", has_gpu = true, location = "Salt Lake City, Utah, USA", icon = "/emojis/1f1fa-1f1f8.png" },

    { zone = "us-west4-a", has_gpu = true, location = "Las Vegas, Nevada, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-west4-b", has_gpu = true, location = "Las Vegas, Nevada, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-west4-c", has_gpu = true, location = "Las Vegas, Nevada, USA", icon = "/emojis/1f1fa-1f1f8.png" },

    # US South
    { zone = "us-south1-a", has_gpu = false, location = "Dallas, Texas, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-south1-b", has_gpu = false, location = "Dallas, Texas, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-south1-c", has_gpu = false, location = "Dallas, Texas, USA", icon = "/emojis/1f1fa-1f1f8.png" },

    # Canada
    { zone = "northamerica-northeast1-a", has_gpu = true, location = "Montréal, Québec, Canada", icon = "/emojis/1f1e8-1f1f6.png" },
    { zone = "northamerica-northeast1-b", has_gpu = true, location = "Montréal, Québec, Canada", icon = "/emojis/1f1e8-1f1f6.png" },
    { zone = "northamerica-northeast1-c", has_gpu = true, location = "Montréal, Québec, Canada", icon = "/emojis/1f1e8-1f1f6.png" },

    { zone = "northamerica-northeast2-a", has_gpu = false, location = "Toronto, Ontario, Canada", icon = "/emojis/1f1e8-1f1f6.png" },
    { zone = "northamerica-northeast2-b", has_gpu = false, location = "Toronto, Ontario, Canada", icon = "/emojis/1f1e8-1f1f6.png" },
    { zone = "northamerica-northeast2-c", has_gpu = false, location = "Toronto, Ontario, Canada", icon = "/emojis/1f1e8-1f1f6.png" },

    # South America East (Brazil, Chile)
    { zone = "southamerica-east1-a", has_gpu = true, location = "Osasco, São Paulo, Brazil", icon = "/emojis/1f1e7-1f1f7.png" },
    { zone = "southamerica-east1-b", has_gpu = false, location = "Osasco, São Paulo, Brazil", icon = "/emojis/1f1e7-1f1f7.png" },
    { zone = "southamerica-east1-c", has_gpu = true, location = "Osasco, São Paulo, Brazil", icon = "/emojis/1f1e7-1f1f7.png" },

    { zone = "southamerica-west1-a", has_gpu = false, location = "Santiago, Chile", icon = "/emojis/1f1e8-1f1f1.png" },
    { zone = "southamerica-west1-b", has_gpu = false, location = "Santiago, Chile", icon = "/emojis/1f1e8-1f1f1.png" },
    { zone = "southamerica-west1-c", has_gpu = false, location = "Santiago, Chile", icon = "/emojis/1f1e8-1f1f1.png" },

    # Europe North (Finland)
    { zone = "europe-north1-a", has_gpu = false, location = "Hamina, Finland", icon = "/emojis/1f1e7-1f1ee.png" },
    { zone = "europe-north1-b", has_gpu = false, location = "Hamina, Finland", icon = "/emojis/1f1e7-1f1ee.png" },
    { zone = "europe-north1-c", has_gpu = false, location = "Hamina, Finland", icon = "/emojis/1f1e7-1f1ee.png" },

    # Europe Central (Poland)
    { zone = "europe-central2-a", has_gpu = false, location = "Warsaw, Poland", icon = "/emojis/1f1f5-1f1f1.png" },
    { zone = "europe-central2-b", has_gpu = true, location = "Warsaw, Poland", icon = "/emojis/1f1f5-1f1f1.png" },
    { zone = "europe-central2-c", has_gpu = true, location = "Warsaw, Poland", icon = "/emojis/1f1f5-1f1f1.png" },

    # Europe Southwest (Spain)
    { zone = "europe-southwest1-a", has_gpu = false, location = "Madrid, Spain", icon = "/emojis/1f1ea-1f1f8.png" },
    { zone = "europe-southwest1-b", has_gpu = false, location = "Madrid, Spain", icon = "/emojis/1f1ea-1f1f8.png" },
    { zone = "europe-southwest1-c", has_gpu = false, location = "Madrid, Spain", icon = "/emojis/1f1ea-1f1f8.png" },

    # Europe West
    { zone = "europe-west1-b", has_gpu = true, location = "St. Ghislain, Belgium", icon = "/emojis/1f1e7-1f1ea.png" },
    { zone = "europe-west1-c", has_gpu = true, location = "St. Ghislain, Belgium", icon = "/emojis/1f1e7-1f1ea.png" },
    { zone = "europe-west1-d", has_gpu = true, location = "St. Ghislain, Belgium", icon = "/emojis/1f1e7-1f1ea.png" },

    { zone = "europe-west2-a", has_gpu = true, location = "London, England", icon = "/emojis/1f173–1f1ff.png" },
    { zone = "europe-west2-b", has_gpu = true, location = "London, England", icon = "/emojis/1f173–1f1ff.png" },
    { zone = "europe-west2-c", has_gpu = false, location = "London, England", icon = "/emojis/1f173–1f1ff.png" },

    { zone = "europe-west3-b", has_gpu = false, location = "Frankfurt, Germany", icon = "/emojis/1f1e9-1f1ea.png" },
    { zone = "europe-west3-c", has_gpu = true, location = "Frankfurt, Germany", icon = "/emojis/1f1e9-1f1ea.png" },
    { zone = "europe-west3-d", has_gpu = false, location = "Frankfurt, Germany", icon = "/emojis/1f1e9-1f1ea.png" },

    { zone = "europe-west4-a", has_gpu = true, location = "Eemshaven, Netherlands", icon = "/emojis/1f1f3-1f1f1.png" },
    { zone = "europe-west4-b", has_gpu = true, location = "Eemshaven, Netherlands", icon = "/emojis/1f1f3-1f1f1.png" },
    { zone = "europe-west4-c", has_gpu = true, location = "Eemshaven, Netherlands", icon = "/emojis/1f1f3-1f1f1.png" },

    { zone = "europe-west6-a", has_gpu = false, location = "Zurich, Switzerland", icon = "/emojis/1f1e8-1f1ed.png" },
    { zone = "europe-west6-b", has_gpu = false, location = "Zurich, Switzerland", icon = "/emojis/1f1e8-1f1ed.png" },
    { zone = "europe-west6-c", has_gpu = false, location = "Zurich, Switzerland", icon = "/emojis/1f1e8-1f1ed.png" },

    { zone = "europe-west8-a", has_gpu = false, location = "Milan, Italy", icon = "/emojis/1f1ee-1f1f9.png" },
    { zone = "europe-west8-b", has_gpu = false, location = "Milan, Italy", icon = "/emojis/1f1ee-1f1f9.png" },
    { zone = "europe-west8-c", has_gpu = false, location = "Milan, Italy", icon = "/emojis/1f1ee-1f1f9.png" },

    { zone = "europe-west9-a", has_gpu = false, location = "Paris, France", icon = "/emojis/1f1eb-1f1f7.png" },
    { zone = "europe-west9-b", has_gpu = false, location = "Paris, France", icon = "/emojis/1f1eb-1f1f7.png" },
    { zone = "europe-west9-c", has_gpu = false, location = "Paris, France", icon = "/emojis/1f1eb-1f1f7.png" },

    { zone = "europe-west10-a", has_gpu = false, location = "Berlin, Germany", icon = "/emojis/1f1e9-1f1ea.png" },
    { zone = "europe-west10-b", has_gpu = false, location = "Berlin, Germany", icon = "/emojis/1f1e9-1f1ea.png" },
    { zone = "europe-west10-c", has_gpu = false, location = "Berlin, Germany", icon = "/emojis/1f1e9-1f1ea.png" },

    { zone = "europe-west12-a", has_gpu = false, location = "Turin, Italy", icon = "/emojis/1f1ee-1f1f9.png" },
    { zone = "europe-west12-b", has_gpu = false, location = "Turin, Italy", icon = "/emojis/1f1ee-1f1f9.png" },
    { zone = "europe-west12-c", has_gpu = false, location = "Turin, Italy", icon = "/emojis/1f1ee-1f1f9.png" },

    # Middleeast Central (Qatar, Saudi Arabia)
    { zone = "me-central1-a", has_gpu = false, location = "Doha, Qatar", icon = "/emojis/1f1f6-1f1e6.png" },
    { zone = "me-central1-b", has_gpu = false, location = "Doha, Qatar", icon = "/emojis/1f1f6-1f1e6.png" },
    { zone = "me-central1-c", has_gpu = false, location = "Doha, Qatar", icon = "/emojis/1f1f6-1f1e6.png" },

    { zone = "me-central2-a", has_gpu = false, location = "Dammam, Saudi Arabia", icon = "/emojis/1f1f8-1f1e6.png" },
    { zone = "me-central2-b", has_gpu = false, location = "Dammam, Saudi Arabia", icon = "/emojis/1f1f8-1f1e6.png" },
    { zone = "me-central2-c", has_gpu = false, location = "Dammam, Saudi Arabia", icon = "/emojis/1f1f8-1f1e6.png" },

    # Middleeast West (Israel)
    { zone = "me-west1-a", has_gpu = false, location = "Tel Aviv, Israel", icon = "/emojis/1f1ee-1f1f1.png" },
    { zone = "me-west1-b", has_gpu = true, location = "Tel Aviv, Israel", icon = "/emojis/1f1ee-1f1f1.png" },
    { zone = "me-west1-c", has_gpu = true, location = "Tel Aviv, Israel", icon = "/emojis/1f1ee-1f1f1.png" },

    # Asia East (Taiwan, Hong Kong)
    { zone = "asia-east1-a", has_gpu = true, location = "Changhua County, Taiwan", icon = "/emojis/1f1f9-1f1fc.png" },
    { zone = "asia-east1-b", has_gpu = true, location = "Changhua County, Taiwan", icon = "/emojis/1f1f9-1f1fc.png" },
    { zone = "asia-east1-c", has_gpu = true, location = "Changhua County, Taiwan", icon = "/emojis/1f1f9-1f1fc.png" },

    { zone = "asia-east2-a", has_gpu = true, location = "Hong Kong", icon = "/emojis/1f1ed-1f1f0.png" },
    { zone = "asia-east2-b", has_gpu = false, location = "Hong Kong", icon = "/emojis/1f1ed-1f1f0.png" },
    { zone = "asia-east2-c", has_gpu = true, location = "Hong Kong", icon = "/emojis/1f1ed-1f1f0.png" },

    # Asia Northeast (Japan, South Korea)
    { zone = "asia-northeast1-a", has_gpu = true, location = "Tokyo, Japan", icon = "/emojis/1f1ef-1f1f5.png" },
    { zone = "asia-northeast1-b", has_gpu = false, location = "Tokyo, Japan", icon = "/emojis/1f1ef-1f1f5.png" },
    { zone = "asia-northeast1-c", has_gpu = true, location = "Tokyo, Japan", icon = "/emojis/1f1ef-1f1f5.png" },
    { zone = "asia-northeast2-a", has_gpu = false, location = "Osaka, Japan", icon = "/emojis/1f1ef-1f1f5.png" },
    { zone = "asia-northeast2-b", has_gpu = false, location = "Osaka, Japan", icon = "/emojis/1f1ef-1f1f5.png" },
    { zone = "asia-northeast2-c", has_gpu = false, location = "Osaka, Japan", icon = "/emojis/1f1ef-1f1f5.png" },
    { zone = "asia-northeast3-a", has_gpu = true, location = "Seoul, South Korea", icon = "/emojis/1f1f0-1f1f7.png" },
    { zone = "asia-northeast3-b", has_gpu = true, location = "Seoul, South Korea", icon = "/emojis/1f1f0-1f1f7.png" },
    { zone = "asia-northeast3-c", has_gpu = true, location = "Seoul, South Korea", icon = "/emojis/1f1f0-1f1f7.png" },

    # Asia South (India)
    { zone = "asia-south1-a", has_gpu = true, location = "Mumbai, India", icon = "/emojis/1f1ee-1f1f3.png" },
    { zone = "asia-south1-b", has_gpu = true, location = "Mumbai, India", icon = "/emojis/1f1ee-1f1f3.png" },
    { zone = "asia-south1-c", has_gpu = false, location = "Mumbai, India", icon = "/emojis/1f1ee-1f1f3.png" },
    { zone = "asia-south2-a", has_gpu = false, location = "Delhi, India", icon = "/emojis/1f1ee-1f1f3.png" },
    { zone = "asia-south2-b", has_gpu = false, location = "Delhi, India", icon = "/emojis/1f1ee-1f1f3.png" },
    { zone = "asia-south2-c", has_gpu = false, location = "Delhi, India", icon = "/emojis/1f1ee-1f1f3.png" },

    # Asia Southeast (Singapore, Indonesia)
    { zone = "asia-southeast1-a", has_gpu = true, location = "Jurong West, Singapore", icon = "/emojis/1f1f8-1f1ec.png" },
    { zone = "asia-southeast1-b", has_gpu = true, location = "Jurong West, Singapore", icon = "/emojis/1f1f8-1f1ec.png" },
    { zone = "asia-southeast1-c", has_gpu = true, location = "Jurong West, Singapore", icon = "/emojis/1f1f8-1f1ec.png" },
    { zone = "asia-southeast2-a", has_gpu = true, location = "Jakarta, Indonesia", icon = "/emojis/1f1ee-1f1e9.png" },
    { zone = "asia-southeast2-b", has_gpu = true, location = "Jakarta, Indonesia", icon = "/emojis/1f1ee-1f1e9.png" },
    { zone = "asia-southeast2-c", has_gpu = true, location = "Jakarta, Indonesia", icon = "/emojis/1f1ee-1f1e9.png" },

    # Australia (Sydney, Melbourne)
    { zone = "australia-southeast1-a", has_gpu = true, location = "Sydney, Australia", icon = "/emojis/1f1e6-1f1fa.png" },
    { zone = "australia-southeast1-b", has_gpu = true, location = "Sydney, Australia", icon = "/emojis/1f1e6-1f1fa.png" },
    { zone = "australia-southeast1-c", has_gpu = true, location = "Sydney, Australia", icon = "/emojis/1f1e6-1f1fa.png" },
    { zone = "australia-southeast2-a", has_gpu = false, location = "Melbourne, Australia", icon = "/emojis/1f1e6-1f1fa.png" },
    { zone = "australia-southeast2-b", has_gpu = false, location = "Melbourne, Australia", icon = "/emojis/1f1e6-1f1fa.png" },
    { zone = "australia-southeast2-c", has_gpu = false, location = "Melbourne, Australia", icon = "/emojis/1f1e6-1f1fa.png" },
  ]
}

data "coder_parameter" "gcp_zones" {
  type         = "list(string)"
  name         = "gcp_zones"
  display_name = "GCP Zones"
  icon         = "/icon/gcp.svg"
  mutable      = true

  dynamic "option" {
    for_each = [for z in local.all_zones : z if contains(var.gcp_regions, substr(z.zone, 0, index(z.zone, "-"))) && (!var.gpu_only || z.has_gpu)]
    content {
      icon        = option.value.icon
      name        = option.value.location
      description = option.value.zone
      value       = option.value.zone
    }
  }
}
