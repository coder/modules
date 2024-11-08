terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.17"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.0"
    }
  }
}

variable "agent_id" {
  type        = string
  description = "The ID of a Coder agent."
}

variable "slug" {
  type        = string
  description = "The slug for the coder_app"
  default     = "gateway"
}

variable "agent_name" {
  type        = string
  description = "Agent name."
}

variable "folder" {
  type        = string
  description = "The directory to open in the IDE. e.g. /home/coder/project"
  validation {
    condition     = can(regex("^(?:/[^/]+)+$", var.folder))
    error_message = "The folder must be a full path and must not start with a ~."
  }
}

variable "default" {
  default     = []
  type        = list(string)
  description = "Default IDEs to be added to the Workspace page."
}

variable "order" {
  type        = number
  description = "The order determines the position of app in the UI presentation. The lowest order is shown first and apps with equal order are sorted by name (ascending order)."
  default     = null
}

variable "coder_parameter_order" {
  type        = number
  description = "The order determines the position of a template parameter in the UI/CLI presentation. The lowest order is shown first and parameters with equal order are sorted by name (ascending order)."
  default     = null
}

variable "latest" {
  type        = bool
  description = "Whether to fetch the latest version of the IDE."
  default     = false
}

variable "channel" {
  type        = string
  description = "JetBrains IDE release channel. Valid values are release and eap."
  default     = "release"
  validation {
    condition     = can(regex("^(release|eap)$", var.channel))
    error_message = "The channel must be either release or eap."
  }
}

variable "jetbrains_ide_versions" {
  type = map(object({
    build_number = string
    version      = string
  }))
  description = "The set of versions for each jetbrains IDE"
  default = {
    "IU" = {
      build_number = "241.14494.240"
      version      = "2024.1"
    }
    "PS" = {
      build_number = "241.14494.237"
      version      = "2024.1"
    }
    "WS" = {
      build_number = "241.14494.235"
      version      = "2024.1"
    }
    "PY" = {
      build_number = "241.14494.241"
      version      = "2024.1"
    }
    "CL" = {
      build_number = "241.14494.288"
      version      = "2024.1"
    }
    "GO" = {
      build_number = "241.14494.238"
      version      = "2024.1"
    }
    "RM" = {
      build_number = "241.14494.234"
      version      = "2024.1"
    }
    "RD" = {
      build_number = "241.14494.307"
      version      = "2024.1"
    }
  }
  validation {
    condition = (
      alltrue([
        for code in keys(var.jetbrains_ide_versions) : contains(["IU", "PS", "WS", "PY", "CL", "GO", "RM", "RD"], code)
      ])
    )
    error_message = "The jetbrains_ide_versions must contain a map of valid product codes. Valid product codes are ${join(",", ["IU", "PS", "WS", "PY", "CL", "GO", "RM", "RD"])}."
  }
}

variable "jetbrains_ides" {
  type        = list(string)
  description = "The list of IDE product codes."
  default     = ["IU", "PS", "WS", "PY", "CL", "GO", "RM", "RD"]
  validation {
    condition = (
      alltrue([
        for code in var.jetbrains_ides : contains(["IU", "PS", "WS", "PY", "CL", "GO", "RM", "RD"], code)
      ])
    )
    error_message = "The jetbrains_ides must be a list of valid product codes. Valid product codes are ${join(",", ["IU", "PS", "WS", "PY", "CL", "GO", "RM", "RD"])}."
  }
  # check if the list is empty
  validation {
    condition     = length(var.jetbrains_ides) > 0
    error_message = "The jetbrains_ides must not be empty."
  }
  # check if the list contains duplicates
  validation {
    condition     = length(var.jetbrains_ides) == length(toset(var.jetbrains_ides))
    error_message = "The jetbrains_ides must not contain duplicates."
  }
}

variable "releases_base_link" {
  type        = string
  description = ""
  default     = "https://data.services.jetbrains.com"
  validation {
    condition     = can(regex("^https?://.+$", var.releases_base_link))
    error_message = "The releases_base_link must be a valid HTTP/S address."
  }
}

variable "download_base_link" {
  type        = string
  description = ""
  default     = "https://download.jetbrains.com"
  validation {
    condition     = can(regex("^https?://.+$", var.download_base_link))
    error_message = "The download_base_link must be a valid HTTP/S address."
  }
}

variable "provide_options" {
  type        = bool
  description = "Whether to provide coder_parameter options."
  default     = true
}

data "http" "jetbrains_ide_versions" {
  for_each = var.latest ? toset(var.jetbrains_ides) : toset([])
  url      = "${var.releases_base_link}/products/releases?code=${each.key}&latest=true&type=${var.channel}"
}

locals {
  jetbrains_ides = {
    "GO" = {
      icon          = "/icon/goland.svg",
      name          = "GoLand",
      identifier    = "GO",
      build_number  = var.jetbrains_ide_versions["GO"].build_number,
      download_link = "${var.download_base_link}/go/goland-${var.jetbrains_ide_versions["GO"].version}.tar.gz"
      version       = var.jetbrains_ide_versions["GO"].version
    },
    "WS" = {
      icon          = "/icon/webstorm.svg",
      name          = "WebStorm",
      identifier    = "WS",
      build_number  = var.jetbrains_ide_versions["WS"].build_number,
      download_link = "${var.download_base_link}/webstorm/WebStorm-${var.jetbrains_ide_versions["WS"].version}.tar.gz"
      version       = var.jetbrains_ide_versions["WS"].version
    },
    "IU" = {
      icon          = "/icon/intellij.svg",
      name          = "IntelliJ IDEA Ultimate",
      identifier    = "IU",
      build_number  = var.jetbrains_ide_versions["IU"].build_number,
      download_link = "${var.download_base_link}/idea/ideaIU-${var.jetbrains_ide_versions["IU"].version}.tar.gz"
      version       = var.jetbrains_ide_versions["IU"].version
    },
    "PY" = {
      icon          = "/icon/pycharm.svg",
      name          = "PyCharm Professional",
      identifier    = "PY",
      build_number  = var.jetbrains_ide_versions["PY"].build_number,
      download_link = "${var.download_base_link}/python/pycharm-professional-${var.jetbrains_ide_versions["PY"].version}.tar.gz"
      version       = var.jetbrains_ide_versions["PY"].version
    },
    "CL" = {
      icon          = "/icon/clion.svg",
      name          = "CLion",
      identifier    = "CL",
      build_number  = var.jetbrains_ide_versions["CL"].build_number,
      download_link = "${var.download_base_link}/cpp/CLion-${var.jetbrains_ide_versions["CL"].version}.tar.gz"
      version       = var.jetbrains_ide_versions["CL"].version
    },
    "PS" = {
      icon          = "/icon/phpstorm.svg",
      name          = "PhpStorm",
      identifier    = "PS",
      build_number  = var.jetbrains_ide_versions["PS"].build_number,
      download_link = "${var.download_base_link}/webide/PhpStorm-${var.jetbrains_ide_versions["PS"].version}.tar.gz"
      version       = var.jetbrains_ide_versions["PS"].version
    },
    "RM" = {
      icon          = "/icon/rubymine.svg",
      name          = "RubyMine",
      identifier    = "RM",
      build_number  = var.jetbrains_ide_versions["RM"].build_number,
      download_link = "${var.download_base_link}/ruby/RubyMine-${var.jetbrains_ide_versions["RM"].version}.tar.gz"
      version       = var.jetbrains_ide_versions["RM"].version
    }
    "RD" = {
      icon          = "/icon/rider.svg",
      name          = "Rider",
      identifier    = "RD",
      build_number  = var.jetbrains_ide_versions["RD"].build_number,
      download_link = "${var.download_base_link}/rider/JetBrains.Rider-${var.jetbrains_ide_versions["RD"].version}.tar.gz"
      version       = var.jetbrains_ide_versions["RD"].version
    }
  }

  default_ide_map = {
    for ide in var.default : ide => local.jetbrains_ides[ide]
  }
}

data "coder_parameter" "jetbrains_ide" {
  for_each     = local.default_ide_map
  type         = "string"
  name         = "jetbrains_ide_${index(each.key) + 1}"
  display_name = "JetBrains IDE ${index(each.key) + 1}"
  icon         = "/icon/gateway.svg"
  mutable      = true
  default      = each.key
  order        = var.coder_parameter_order

  dynamic "option" {
    for_each = var.jetbrains_ides
    content {
      icon  = local.jetbrains_ides[option.value].icon
      name  = local.jetbrains_ides[option.value].name
      value = option.value
    }
  }
}

data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}

resource "coder_app" "gateway" {
  for_each     = local.default_ide_map
  agent_id     = var.agent_id
  slug         = "${var.slug}-${lower(each.key)}"
  display_name = each.value.name
  icon         = each.value.icon
  external     = true
  order        = var.order
  url = join("", [
    "jetbrains-gateway://connect#type=coder&workspace=",
    data.coder_workspace.me.name,
    "&owner=",
    data.coder_workspace_owner.me.name,
    "&agent=",
    var.agent_name,
    "&folder=",
    var.folder,
    "&url=",
    data.coder_workspace.me.access_url,
    "&token=",
    "$SESSION_TOKEN",
    "&ide_product_code=",
    each.key,
    "&ide_build_number=",
    each.value.build_number,
    "&ide_download_link=",
    each.value.download_link,
  ])
}

output "coder_apps" {
  value = {
    for key, app in coder_app.gateway : key => {
      identifier    = key
      display_name  = app.display_name
      icon          = local.jetbrains_ides[key].icon
      download_link = local.jetbrains_ides[key].download_link
      build_number  = local.jetbrains_ides[key].build_number
      version       = local.jetbrains_ides[key].version
    }
  }
}
