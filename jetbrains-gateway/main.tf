terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.17"
    }
  }
}

variable "agent_id" {
  type        = string
  description = "The ID of a Coder agent."
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
  default     = ""
  type        = string
  description = "Default IDE"
}

variable "order" {
  type        = number
  description = "The order determines the position of app in the UI presentation. The lowest order is shown first and apps with equal order are sorted by name (ascending order)."
  default     = null
}

variable "jetbrains_ide_versions" {
  type = map(object({
    build_number = string
    version      = string
  }))
  description = "The set of versions for each jetbrains IDE"
  default = {
    "IU" = {
      build_number = "232.10203.10"
      version      = "2023.2.4"
    }
    "PS" = {
      build_number = "232.10072.32"
      version      = "2023.2.3"
    }
    "WS" = {
      build_number = "232.10203.14"
      version      = "2023.2.4"
    }
    "PY" = {
      build_number = "232.10203.26"
      version      = "2023.2.4"
    }
    "CL" = {
      build_number = "232.9921.42"
      version      = "2023.2.2"
    }
    "GO" = {
      build_number = "232.10203.20"
      version      = "2023.2.4"
    }
    "RM" = {
      build_number = "232.10203.15"
      version      = "2023.2.4"
    }
    "RD" = {
      build_number = "232.10300.49"
      version      = "2023.2.4"
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

locals {
  jetbrains_ides = {
    "GO" = {
      icon          = "/icon/goland.svg",
      name          = "GoLand",
      identifier    = "GO",
      build_number  = var.jetbrains_ide_versions["GO"].build_number,
      download_link = "https://download.jetbrains.com/go/goland-${var.jetbrains_ide_versions["GO"].version}.tar.gz"
    },
    "WS" = {
      icon          = "/icon/webstorm.svg",
      name          = "WebStorm",
      identifier    = "WS",
      build_number  = var.jetbrains_ide_versions["WS"].build_number,
      download_link = "https://download.jetbrains.com/webstorm/WebStorm-${var.jetbrains_ide_versions["WS"].version}.tar.gz"
    },
    "IU" = {
      icon          = "/icon/intellij.svg",
      name          = "IntelliJ IDEA Ultimate",
      identifier    = "IU",
      build_number  = var.jetbrains_ide_versions["IU"].build_number,
      download_link = "https://download.jetbrains.com/idea/ideaIU-${var.jetbrains_ide_versions["IU"].version}.tar.gz"
    },
    "PY" = {
      icon          = "/icon/pycharm.svg",
      name          = "PyCharm Professional",
      identifier    = "PY",
      build_number  = var.jetbrains_ide_versions["PY"].build_number,
      download_link = "https://download.jetbrains.com/python/pycharm-professional-${var.jetbrains_ide_versions["PY"].version}.tar.gz"
    },
    "CL" = {
      icon          = "/icon/clion.svg",
      name          = "CLion",
      identifier    = "CL",
      build_number  = var.jetbrains_ide_versions["CL"].build_number,
      download_link = "https://download.jetbrains.com/cpp/CLion-${var.jetbrains_ide_versions["CL"].version}.tar.gz"
    },
    "PS" = {
      icon          = "/icon/phpstorm.svg",
      name          = "PhpStorm",
      identifier    = "PS",
      build_number  = var.jetbrains_ide_versions["PS"].build_number,
      download_link = "https://download.jetbrains.com/webide/PhpStorm-${var.jetbrains_ide_versions["PS"].version}.tar.gz"
    },
    "RM" = {
      icon          = "/icon/rubymine.svg",
      name          = "RubyMine",
      identifier    = "RM",
      build_number  = var.jetbrains_ide_versions["RM"].build_number,
      download_link = "https://download.jetbrains.com/ruby/RubyMine-${var.jetbrains_ide_versions["RM"].version}.tar.gz"
    }
    "RD" = {
      icon          = "/icon/rider.svg",
      name          = "Rider",
      identifier    = "RD",
      build_number  = var.jetbrains_ide_versions["RD"].build_number,
      download_link = "https://download.jetbrains.com/rider/JetBrains.Rider-${var.jetbrains_ide_versions["RD"].version}.tar.gz"
    }
  }
}

data "coder_parameter" "jetbrains_ide" {
  type         = "string"
  name         = "jetbrains_ide"
  display_name = "JetBrains IDE"
  icon         = "/icon/gateway.svg"
  mutable      = true
  default      = var.default == "" ? var.jetbrains_ides[0] : var.default

  dynamic "option" {
    for_each = var.jetbrains_ides
    content {
      icon  = lookup(local.jetbrains_ides, option.value).icon
      name  = lookup(local.jetbrains_ides, option.value).name
      value = lookup(local.jetbrains_ides, option.value).identifier
    }
  }
}

data "coder_workspace" "me" {}

resource "coder_app" "gateway" {
  agent_id     = var.agent_id
  slug         = "gateway"
  display_name = try(lookup(local.jetbrains_ides, data.coder_parameter.jetbrains_ide.value).name, "JetBrains IDE")
  icon         = try(lookup(local.jetbrains_ides, data.coder_parameter.jetbrains_ide.value).icon, "/icon/gateway.svg")
  external     = true
  order        = var.order
  url = join("", [
    "jetbrains-gateway://connect#type=coder&workspace=",
    data.coder_workspace.me.name,
    "&agent=",
    var.agent_name,
    "&folder=",
    var.folder,
    "&url=",
    data.coder_workspace.me.access_url,
    "&token=",
    "$SESSION_TOKEN",
    "&ide_product_code=",
    local.jetbrains_ides[data.coder_parameter.jetbrains_ide.value].identifier,
    "&ide_build_number=",
    local.jetbrains_ides[data.coder_parameter.jetbrains_ide.value].build_number,
    "&ide_download_link=",
    local.jetbrains_ides[data.coder_parameter.jetbrains_ide.value].download_link
  ])
}

output "identifier" {
  value = data.coder_parameter.jetbrains_ide.value
}

output "name" {
  value = coder_app.gateway.display_name
}

output "icon" {
  value = coder_app.gateway.icon
}

output "download_link" {
  value = lookup(local.jetbrains_ides, data.coder_parameter.jetbrains_ide.value).download_link
}

output "build_number" {
  value = lookup(local.jetbrains_ides, data.coder_parameter.jetbrains_ide.value).build_number
}

output "version" {
  value = var.jetbrains_ide_versions[data.coder_parameter.jetbrains_ide.value].version
}

output "url" {
  value = coder_app.gateway.url
}
