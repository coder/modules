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
  description = "The slug for the coder_app. Allows resuing the module with the same template."
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
  description = "List of default IDEs to be added to the Workspace page."
  # check if the list is unique
  validation {
    condition     = length(var.default) == length(toset(var.default))
    error_message = "The default must not contain duplicates."
  }
  # check if default are valid jetbrains_ides
  validation {
    condition = (
      alltrue([
        for code in var.default : contains(["IU", "PS", "WS", "PY", "CL", "GO", "RM", "RD"], code)
      ])
    )
    error_message = "The default must be a list of valid product codes. Valid product codes are ${join(",", ["IU", "PS", "WS", "PY", "CL", "GO", "RM", "RD"])}."
  }
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
  description = "The list of IDE product codes to be shown to the user. Does not apply when there are multiple defaults."
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

  identifier = try([data.coder_parameter.jetbrains_ide[0].value], var.default)
  list_json_data = var.latest ? [
    for ide in local.identifier : jsondecode(data.http.jetbrains_ide_versions[ide].response_body)
  ] : []
  list_key = var.latest ? [
    for j in local.list_json_data : keys(j)[0]
  ] : []
  download_links = length(local.list_key) > 0 ? [
    for i, j in local.list_json_data : j[local.list_key[i]][0].downloads.linux.link
    ] : [
    for ide in local.identifier : local.jetbrains_ides[ide].download_link
  ]
  build_numbers = length(local.list_key) > 0 ? [
    for i, j in local.list_json_data : j[local.list_key[i]][0].build
    ] : [
    for ide in local.identifier : local.jetbrains_ides[ide].build_number
  ]
  versions = length(local.list_key) > 0 ? [
    for i, j in local.list_json_data : j[local.list_key[i]][0].version
    ] : [
    for ide in local.identifier : local.jetbrains_ides[ide].version
  ]
  display_names = [for key in keys(coder_app.gateway) : coder_app.gateway[key].display_name]
  icons         = [for key in keys(coder_app.gateway) : coder_app.gateway[key].icon]
  urls          = [for key in keys(coder_app.gateway) : coder_app.gateway[key].url]
}

data "coder_parameter" "jetbrains_ide" {
  # remove the coder_parameter if there are multiple default
  count        = length(var.default) > 1 ? 0 : 1
  type         = "string"
  name         = "jetbrains_ide"
  display_name = "JetBrains IDE"
  icon         = "/icon/gateway.svg"
  mutable      = true
  default      = length(var.default) > 0 ? var.default[0] : var.jetbrains_ides[0]
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
  for_each     = length(var.default) > 1 ? toset(var.default) : toset([data.coder_parameter.jetbrains_ide[0].value])
  agent_id     = var.agent_id
  slug         = "${var.slug}-${lower(each.value)}"
  display_name = local.jetbrains_ides[each.value].name
  icon         = local.jetbrains_ides[each.value].icon
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
    each.value,
    "&ide_build_number=",
    local.jetbrains_ides[each.value].build_number,
    "&ide_download_link=",
    local.jetbrains_ides[each.value].download_link,
  ])
}

output "identifier" {
  value       = local.identifier
  description = "The product code of the JetBrains IDE."
}

output "display_name" {
  value       = [for key in keys(coder_app.gateway) : coder_app.gateway[key].display_name]
  description = "The display name of the JetBrains IDE."
}

output "icon" {
  value       = [for key in keys(coder_app.gateway) : coder_app.gateway[key].icon]
  description = "The icon of the JetBrains IDE."
}

output "download_link" {
  value       = local.download_links
  description = "The download link of the JetBrains IDE."
}

output "build_number" {
  value       = local.build_numbers
  description = "The build number of the JetBrains IDE."
}

output "version" {
  value       = local.versions
  description = "The version of the JetBrains IDE."
}

output "url" {
  value       = [for key in keys(coder_app.gateway) : coder_app.gateway[key].url]
  description = "The URL to connect to the JetBrains IDE."
}