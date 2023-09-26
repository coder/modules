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
    default = "Fly.io Region"
    description = "The display name of the parameter."
    type = string
}

variable "description" {
    default = "The region to deploy workspace infrastructure."
    description = "The description of the parameter."
    type = string
}

variable "default" {
    default = "us-east-1"
    description = "The default region to use if no region is specified."
    type = string
}

variable "mutable" {
    default = false
    description = "Whether the parameter can be changed after creation."
    type = bool
}

locals {
  regions = { 
    "ams" = {
      name = "Amsterdam, Netherlands"
      gateway = true
      paid_only = false
      icon = "/emojis/TODO.png"
    }
    "arn" = {
      name = "Stockholm, Sweden"
      gateway = false
      paid_only = false
      icon = "/emojis/TODO.png"
    }
    "atl" = {
      name = "Atlanta, Georgia (US)"
      gateway = false
      paid_only = false
      icon = "/emojis/1f1fa-1f1f8.png"
    }
    "bog" = {
      name = "Bogotá, Colombia"
      gateway = false
      paid_only = false
      icon = "/emojis/TODO.png"
    }
    "bom" = {
      name = "Mumbai, India"
      gateway = true
      paid_only = true
      icon = "/emojis/TODO.png"
    }
    "bos" = {
      name = "Boston, Massachusetts (US)"
      gateway = false
      paid_only = false
      icon = "/emojis/1f1fa-1f1f8.png"
    }
    "cdg" = {
      name = "Paris, France"
      gateway = true
      paid_only = false
      icon = "/emojis/TODO.png"
    }
    "den" = {
      name = "Denver, Colorado (US)"
      gateway = false
      paid_only = false
      icon = "/emojis/1f1fa-1f1f8.png"
    }
    "dfw" = {
      name = "Dallas, Texas (US)"
      gateway = true
      paid_only = false
      icon = "/emojis/1f1fa-1f1f8.png"
    }
    "ewr" = {
      name = "Secaucus, NJ (US)"
      gateway = false
      paid_only = false
      icon = "/emojis/1f1fa-1f1f8.png"
    }
    "eze" = {
      name = "Ezeiza, Argentina"
      gateway = false
      paid_only = false
      icon = "/emojis/TODO.png"
    }
    "fra" = {
      name = "Frankfurt, Germany"
      gateway = true
      paid_only = true
      icon = "/emojis/TODO.png"
    }
    "gdl" = {
      name = "Guadalajara, Mexico"
      gateway = false
      paid_only = false
      icon = "/emojis/TODO.png"
    }
    "gig" = {
      name = "Rio de Janeiro, Brazil"
      gateway = false
      paid_only = false
      icon = "/emojis/TODO.png"
    }
    "gru" = {
      name = "Sao Paulo, Brazil"
      gateway = false
      paid_only = false
      icon = "/emojis/TODO.png"
    }
    "hkg" = {
      name = "Hong Kong, Hong Kong"
      gateway = true
      paid_only = false
      icon = "/emojis/TODO.png"
    }
    "iad" = {
      name = "Ashburn, Virginia (US)"
      gateway = true
      paid_only = false
      icon = "/emojis/1f1fa-1f1f8.png"
    }
    "jnb" = {
      name = "Johannesburg, South Africa"
      gateway = false
      paid_only = false
      icon = "/emojis/TODO.png"
    }
    "lax" = {
      name = "Los Angeles, California (US)"
      gateway = true
      paid_only = false
      icon = "/emojis/1f1fa-1f1f8.png"
    }
    "lhr" = {
      name = "London, United Kingdom"
      gateway = true
      paid_only = false
      icon = "/emojis/TODO.png"
    }
    "mad" = {
      name = "Madrid, Spain"
      gateway = false
      paid_only = false
      icon = "/emojis/TODO.png"
    }
    "mia" = {
      name = "Miami, Florida (US)"
      gateway = false
      paid_only = false
      icon = "/emojis/1f1fa-1f1f8.png"
    }
    "nrt" = {
      name = "Tokyo, Japan"
      gateway = true
      paid_only = false
      icon = "/emojis/TODO.png"
    }
    "ord" = {
      name = "Chicago, Illinois (US)"
      gateway = true
      paid_only = false
      icon = "/emojis/1f1fa-1f1f8.png"
    }
    "otp" = {
      name = "Bucharest, Romania"
      gateway = false
      paid_only = false
      icon = "/emojis/TODO.png"
    }
    "phx" = {
      name = "Phoenix, Arizona (US)"
      gateway = false
      paid_only = false
      icon = "/emojis/1f1fa-1f1f8.png"
    }
    "qro" = {
      name = "Querétaro, Mexico"
      gateway = false
      paid_only = false
      icon = "/emojis/TODO.png"
    }
    "scl" = {
      name = "Santiago, Chile"
      gateway = true
      paid_only = false
      icon = "/emojis/TODO.png"
    }
    "sea" = {
      name = "Seattle, Washington (US)"
      gateway = true
      paid_only = false
      icon = "/emojis/1f1fa-1f1f8.png"
    }
    "sin" = {
      name = "Singapore, Singapore"
      gateway = true
      paid_only = false
      icon = "/emojis/TODO.png"
    }
    "sjc" = {
      name = "San Jose, California (US)"
      gateway = true
      paid_only = false
      icon = "/emojis/1f1fa-1f1f8.png"
    }
    "syd" = {
      name = "Sydney, Australia"
      gateway = true
      paid_only = false
      icon = "/emojis/TODO.png"
    }
    "waw" = {
      name = "Warsaw, Poland"
      gateway = false
      paid_only = false
      icon = "/emojis/TODO.png"
    }
    "yul" = {
      name = "Montreal, Canada"
      gateway = false
      paid_only = false
      icon = "/emojis/1f1e8-1f1e6.png"
    }
    "yyz" = {
      name = "Toronto, Canada"
      gateway = true
      paid_only = false
      icon = "/emojis/1f1e8-1f1e6.png"
    }
  }
}