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

locals {
  all_zones = [
    # US Central
    { zone = "us-central1-a", location = "Council Bluffs, Iowa, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-central1-b", location = "Council Bluffs, Iowa, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-central1-c", location = "Council Bluffs, Iowa, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-central1-f", location = "Council Bluffs, Iowa, USA", icon = "/emojis/1f1fa-1f1f8.png" },

    # US East
    { zone = "us-east1-b", location = "Moncks Corner, S. Carolina, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-east1-c", location = "Moncks Corner, S. Carolina, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-east1-d", location = "Moncks Corner, S. Carolina, USA", icon = "/emojis/1f1fa-1f1f8.png" },

    { zone = "us-east4-a", location = "Ashburn, Virginia, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-east4-b", location = "Ashburn, Virginia, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-east4-c", location = "Ashburn, Virginia, USA", icon = "/emojis/1f1fa-1f1f8.png" },

    { zone = "us-east5-a", location = "Columbus, Ohio, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-east5-b", location = "Columbus, Ohio, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-east5-c", location = "Columbus, Ohio, USA", icon = "/emojis/1f1fa-1f1f8.png" },

    # Us West
    { zone = "us-west1-a", location = "The Dalles, Oregon, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-west1-b", location = "The Dalles, Oregon, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-west1-c", location = "The Dalles, Oregon, USA", icon = "/emojis/1f1fa-1f1f8.png" },

    { zone = "us-west2-a", location = "Los Angeles, California, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-west2-b", location = "Los Angeles, California, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-west2-c", location = "Los Angeles, California, USA", icon = "/emojis/1f1fa-1f1f8.png" },

    { zone = "us-west3-a", location = "Salt Lake City, Utah, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-west3-b", location = "Salt Lake City, Utah, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-west3-c", location = "Salt Lake City, Utah, USA", icon = "/emojis/1f1fa-1f1f8.png" },

    { zone = "us-west4-a", location = "Las Vegas, Nevada, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-west4-b", location = "Las Vegas, Nevada, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-west4-c", location = "Las Vegas, Nevada, USA", icon = "/emojis/1f1fa-1f1f8.png" },

    # US South
    { zone = "us-south1-a", location = "Dallas, Texas, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-south1-b", location = "Dallas, Texas, USA", icon = "/emojis/1f1fa-1f1f8.png" },
    { zone = "us-south1-c", location = "Dallas, Texas, USA", icon = "/emojis/1f1fa-1f1f8.png" },

    # Canada
    { zone = "northamerica-northeast1-a", location = "Montréal, Québec, Canada", icon = "/emojis/1f1e8-1f1f6.png" },
    { zone = "northamerica-northeast1-b", location = "Montréal, Québec, Canada", icon = "/emojis/1f1e8-1f1f6.png" },
    { zone = "northamerica-northeast1-c", location = "Montréal, Québec, Canada", icon = "/emojis/1f1e8-1f1f6.png" },

    { zone = "northamerica-northeast2-a", location = "Toronto, Ontario, Canada", icon = "/emojis/1f1e8-1f1f6.png" },
    { zone = "northamerica-northeast2-b", location = "Toronto, Ontario, Canada", icon = "/emojis/1f1e8-1f1f6.png" },
    { zone = "northamerica-northeast2-c", location = "Toronto, Ontario, Canada", icon = "/emojis/1f1e8-1f1f6.png" },

    # South America East (Brazil, Chile)
    { zone = "southamerica-east1-a", location = "Osasco, São Paulo, Brazil", icon = "/emojis/1f1e7-1f1f7.png" },
    { zone = "southamerica-east1-b", location = "Osasco, São Paulo, Brazil", icon = "/emojis/1f1e7-1f1f7.png" },
    { zone = "southamerica-east1-c", location = "Osasco, São Paulo, Brazil", icon = "/emojis/1f1e7-1f1f7.png" },

    { zone = "southamerica-west1-a", location = "Santiago, Chile", icon = "/emojis/1f1e8-1f1f1.png" },
    { zone = "southamerica-west1-b", location = "Santiago, Chile", icon = "/emojis/1f1e8-1f1f1.png" },
    { zone = "southamerica-west1-c", location = "Santiago, Chile", icon = "/emojis/1f1e8-1f1f1.png" },

    # Europe North (Finland)
    { zone = "europe-north1-a", location = "Hamina, Finland", icon = "/emojis/1f1e7-1f1ee.png" },
    { zone = "europe-north1-b", location = "Hamina, Finland", icon = "/emojis/1f1e7-1f1ee.png" },
    { zone = "europe-north1-c", location = "Hamina, Finland", icon = "/emojis/1f1e7-1f1ee.png" },

    # Europe Central (Poland)
    { zone = "europe-central2-a", location = "Warsaw, Poland", icon = "/emojis/1f1f5-1f1f1.png" },
    { zone = "europe-central2-b", location = "Warsaw, Poland", icon = "/emojis/1f1f5-1f1f1.png" },
    { zone = "europe-central2-c", location = "Warsaw, Poland", icon = "/emojis/1f1f5-1f1f1.png" },

    # Europe Southwest (Spain)
    { zone = "europe-southwest1-a", location = "Madrid, Spain", icon = "/emojis/1f1ea-1f1f8.png" },
    { zone = "europe-southwest1-b", location = "Madrid, Spain", icon = "/emojis/1f1ea-1f1f8.png" },
    { zone = "europe-southwest1-c", location = "Madrid, Spain", icon = "/emojis/1f1ea-1f1f8.png" },

    # Europe West
    { zone = "europe-west1-b", location = "St. Ghislain, Belgium", icon = "/emojis/1f1e7-1f1ea.png" },
    { zone = "europe-west1-c", location = "St. Ghislain, Belgium", icon = "/emojis/1f1e7-1f1ea.png" },
    { zone = "europe-west1-d", location = "St. Ghislain, Belgium", icon = "/emojis/1f1e7-1f1ea.png" },

    { zone = "europe-west2-a", location = "London, England", icon = "/emojis/1f173–1f1ff.png" },
    { zone = "europe-west2-b", location = "London, England", icon = "/emojis/1f173–1f1ff.png" },
    { zone = "europe-west2-c", location = "London, England", icon = "/emojis/1f173–1f1ff.png" },

    { zone = "europe-west3-b", location = "Frankfurt, Germany", icon = "/emojis/1f1e9-1f1ea.png" },
    { zone = "europe-west3-c", location = "Frankfurt, Germany", icon = "/emojis/1f1e9-1f1ea.png" },
    { zone = "europe-west3-d", location = "Frankfurt, Germany", icon = "/emojis/1f1e9-1f1ea.png" },

    { zone = "europe-west4-a", location = "Eemshaven, Netherlands", icon = "/emojis/1f1f3-1f1f1.png" },
    { zone = "europe-west4-b", location = "Eemshaven, Netherlands", icon = "/emojis/1f1f3-1f1f1.png" },
    { zone = "europe-west4-c", location = "Eemshaven, Netherlands", icon = "/emojis/1f1f3-1f1f1.png" },

    { zone = "europe-west6-a", location = "Zurich, Switzerland", icon = "/emojis/1f1e8-1f1ed.png" },
    { zone = "europe-west6-b", location = "Zurich, Switzerland", icon = "/emojis/1f1e8-1f1ed.png" },
    { zone = "europe-west6-c", location = "Zurich, Switzerland", icon = "/emojis/1f1e8-1f1ed.png" },

    { zone = "europe-west8-a", location = "Milan, Italy", icon = "/emojis/1f1ee-1f1f9.png" },
    { zone = "europe-west8-b", location = "Milan, Italy", icon = "/emojis/1f1ee-1f1f9.png" },
    { zone = "europe-west8-c", location = "Milan, Italy", icon = "/emojis/1f1ee-1f1f9.png" },

    { zone = "europe-west9-a", location = "Paris, France", icon = "/emojis/1f1eb-1f1f7.png" },
    { zone = "europe-west9-b", location = "Paris, France", icon = "/emojis/1f1eb-1f1f7.png" },
    { zone = "europe-west9-c", location = "Paris, France", icon = "/emojis/1f1eb-1f1f7.png" },

    { zone = "europe-west10-a", location = "Berlin, Germany", icon = "/emojis/1f1e9-1f1ea.png" },
    { zone = "europe-west10-b", location = "Berlin, Germany", icon = "/emojis/1f1e9-1f1ea.png" },
    { zone = "europe-west10-c", location = "Berlin, Germany", icon = "/emojis/1f1e9-1f1ea.png" },

    { zone = "europe-west12-a", location = "Turin, Italy", icon = "/emojis/1f1ee-1f1f9.png" },
    { zone = "europe-west12-b", location = "Turin, Italy", icon = "/emojis/1f1ee-1f1f9.png" },
    { zone = "europe-west12-c", location = "Turin, Italy", icon = "/emojis/1f1ee-1f1f9.png" },

    # Middleeast Central (Qatar, Saudi Arabia)
    { zone = "me-central1-a	", location = "Doha, Qatar", icon = "/emojis/1f1f6-1f1e6.png" },
    { zone = "me-central1-b	", location = "Doha, Qatar", icon = "/emojis/1f1f6-1f1e6.png" },
    { zone = "me-central1-c	", location = "Doha, Qatar", icon = "/emojis/1f1f6-1f1e6.png" },

    { zone = "me-central2-a	", location = "Dammam, Saudi Arabia", icon = "/emojis/1f1f8-1f1e6.png" },
    { zone = "me-central2-b	", location = "Dammam, Saudi Arabia", icon = "/emojis/1f1f8-1f1e6.png" },
    { zone = "me-central2-c	", location = "Dammam, Saudi Arabia", icon = "/emojis/1f1f8-1f1e6.png" },

    # Middleeast West (Israel)
    { zone = "me-west1-a", location = "Tel Aviv, Israel", icon = "/emojis/1f1ee-1f1f1.png" },
    { zone = "me-west1-b", location = "Tel Aviv, Israel", icon = "/emojis/1f1ee-1f1f1.png" },
    { zone = "me-west1-c", location = "Tel Aviv, Israel", icon = "/emojis/1f1ee-1f1f1.png" },

    # Asia East (Taiwan, Hong Kong)
    { zone = "asia-east1-a", location = "Changhua County, Taiwan", icon = "/emojis/1f1f9-1f1fc.png" },
    { zone = "asia-east1-b", location = "Changhua County, Taiwan", icon = "/emojis/1f1f9-1f1fc.png" },
    { zone = "asia-east1-c", location = "Changhua County, Taiwan", icon = "/emojis/1f1f9-1f1fc.png" },

    { zone = "asia-east2-a", location = "Hong Kong", icon = "/emojis/1f1ed-1f1f0.png" },
    { zone = "asia-east2-b", location = "Hong Kong", icon = "/emojis/1f1ed-1f1f0.png" },
    { zone = "asia-east2-c", location = "Hong Kong", icon = "/emojis/1f1ed-1f1f0.png" },

    # Asia Northeast (Japan, South Korea)
    { zone = "asia-northeast1-a", location = "Tokyo, Japan", icon = "/emojis/1f1ef-1f1f5.png" },
    { zone = "asia-northeast1-b", location = "Tokyo, Japan", icon = "/emojis/1f1ef-1f1f5.png" },
    { zone = "asia-northeast1-c", location = "Tokyo, Japan", icon = "/emojis/1f1ef-1f1f5.png" },
    { zone = "asia-northeast2-a", location = "Osaka, Japan", icon = "/emojis/1f1ef-1f1f5.png" },
    { zone = "asia-northeast2-b", location = "Osaka, Japan", icon = "/emojis/1f1ef-1f1f5.png" },
    { zone = "asia-northeast2-c", location = "Osaka, Japan", icon = "/emojis/1f1ef-1f1f5.png" },
    { zone = "asia-northeast3-a", location = "Seoul, South Korea", icon = "/emojis/1f1f0-1f1f7.png" },
    { zone = "asia-northeast3-b", location = "Seoul, South Korea", icon = "/emojis/1f1f0-1f1f7.png" },
    { zone = "asia-northeast3-c", location = "Seoul, South Korea", icon = "/emojis/1f1f0-1f1f7.png" },

    # Asia South (India)
    { zone = "asia-south1-a", location = "Mumbai, India", icon = "/emojis/1f1ee-1f1f3.png" },
    { zone = "asia-south1-b", location = "Mumbai, India", icon = "/emojis/1f1ee-1f1f3.png" },
    { zone = "asia-south1-c", location = "Mumbai, India", icon = "/emojis/1f1ee-1f1f3.png" },
    { zone = "asia-south2-a", location = "Delhi, India", icon = "/emojis/1f1ee-1f1f3.png" },
    { zone = "asia-south2-b", location = "Delhi, India", icon = "/emojis/1f1ee-1f1f3.png" },
    { zone = "asia-south2-c", location = "Delhi, India", icon = "/emojis/1f1ee-1f1f3.png" },

    # Asia Southeast (Singapore, Indonesia)
    { zone = "asia-southeast1-a", location = "Jurong West, Singapore", icon = "/emojis/1f1f8-1f1ec.png" },
    { zone = "asia-southeast1-b", location = "Jurong West, Singapore", icon = "/emojis/1f1f8-1f1ec.png" },
    { zone = "asia-southeast1-c", location = "Jurong West, Singapore", icon = "/emojis/1f1f8-1f1ec.png" },
    { zone = "asia-southeast2-a", location = "Jakarta, Indonesia", icon = "/emojis/1f1ee-1f1e9.png" },
    { zone = "asia-southeast2-b", location = "Jakarta, Indonesia", icon = "/emojis/1f1ee-1f1e9.png" },
    { zone = "asia-southeast2-c", location = "Jakarta, Indonesia", icon = "/emojis/1f1ee-1f1e9.png" },

    # Australia (Sydney, Melbourne)
    { zone = "australia-southeast1-a", location = "Sydney, Australia", icon = "/emojis/1f1e6-1f1fa.png" },
    { zone = "australia-southeast1-b", location = "Sydney, Australia", icon = "/emojis/1f1e6-1f1fa.png" },
    { zone = "australia-southeast1-c", location = "Sydney, Australia", icon = "/emojis/1f1e6-1f1fa.png" },
    { zone = "australia-southeast2-a", location = "Melbourne, Australia", icon = "/emojis/1f1e6-1f1fa.png" },
    { zone = "australia-southeast2-b", location = "Melbourne, Australia", icon = "/emojis/1f1e6-1f1fa.png" },
    { zone = "australia-southeast2-c", location = "Melbourne, Australia", icon = "/emojis/1f1e6-1f1fa.png" },
  ]
}

data "coder_parameter" "aws_zones" {
  type         = "list(string)"
  name         = "aws_zones"
  display_name = "AWS Zones"
  icon         = "/icon/aws.svg"
  mutable      = false

  dynamic "option" {
    for_each = [for z in local.all_zones : z if contains(var.aws_regions, substr(z.zone, 0, index(z.zone, "-")))]
    content {
      icon        = option.value.icon
      name        = option.value.location
      description = option.value.zone
      value       = option.value.zone
    }
  }
}
