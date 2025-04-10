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

variable "coder_app_order" {
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

variable "options" {
  type        = list(string)
  description = "The list of IDE product codes."
  default     = ["CL", "GO", "IU", "PS", "PY", "RD", "RM", "RR", "WS"]
  validation {
    condition = (
      alltrue([
        for code in var.options : contains(["CL", "GO", "IU", "PS", "PY", "RD", "RM", "RR", "WS"], code)
      ])
    )
    error_message = "The options must be a list of valid product codes. Valid product codes are ${join(",", ["CL", "GO", "IU", "PS", "PY", "RD", "RM", "RR", "WS"])}."
  }
  # check if the list is empty
  validation {
    condition     = length(var.options) > 0
    error_message = "The options must not be empty."
  }
  # check if the list contains duplicates
  validation {
    condition     = length(var.options) == length(toset(var.options))
    error_message = "The options must not contain duplicates."
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
  for_each = var.latest ? toset(var.options) : toset([])
  url      = "${var.releases_base_link}/products/releases?code=${each.key}&latest=true&type=${var.channel}"
}

locals {
  # IDE configuration map
  ide_config = {
    "CL" = { name = "CLion", icon = "/icon/clion.svg", build = "251.23774.202" },
    "GO" = { name = "GoLand", icon = "/icon/goland.svg", build = "251.23774.216" },
    "IU" = { name = "IntelliJ IDEA", icon = "/icon/intellij.svg", build = "251.23774.200" },
    "PS" = { name = "PhpStorm", icon = "/icon/phpstorm.svg", build = "251.23774.209" },
    "PY" = { name = "PyCharm", icon = "/icon/pycharm.svg", build = "251.23774.211" },
    "RD" = { name = "Rider", icon = "/icon/rider.svg", build = "251.23774.212" },
    "RM" = { name = "RubyMine", icon = "/icon/rubymine.svg", build = "251.23774.208" },
    "RR" = { name = "RustRover", icon = "/icon/rustrover.svg", build = "251.23774.316" },
    "WS" = { name = "WebStorm", icon = "/icon/webstorm.svg", build = "251.23774.210" }
  }

  # Dynamically generate IDE configurations based on options
  jetbrains_ides = {
    for code in var.options : code => {
      icon       = "/icon/${lower(local.ide_config[code].name)}.svg"
      name       = local.ide_config[code].name
      identifier = code
      build      = local.ide_config[code].build
    }
  }

  icon         = local.jetbrains_ides[data.coder_parameter.jetbrains_ide.value].icon
  json_data    = var.latest ? jsondecode(data.http.jetbrains_ide_versions[data.coder_parameter.jetbrains_ide.value].response_body) : {}
  key          = var.latest ? keys(local.json_data)[0] : ""
  display_name = local.jetbrains_ides[data.coder_parameter.jetbrains_ide.value].name
  identifier   = data.coder_parameter.jetbrains_ide.value
  build        = var.latest ? local.json_data[local.key][0].build : local.ide_config[data.coder_parameter.jetbrains_ide.value].build
}

data "coder_parameter" "jetbrains_ide" {
  type         = "string"
  name         = "jetbrains_ide"
  display_name = "JetBrains IDE"
  icon         = "/icon/gateway.svg"
  mutable      = true
  default      = var.default == "" ? var.options[0] : var.default
  order        = var.coder_parameter_order

  dynamic "option" {
    for_each = var.options
    content {
      icon  = local.jetbrains_ides[option.value].icon
      name  = local.jetbrains_ides[option.value].name
      value = option.value
    }
  }
}

data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}

resource "coder_app" "jetbrains" {
  agent_id     = var.agent_id
  slug         = "jetbrains"
  display_name = local.display_name
  icon         = local.icon
  external     = true
  order        = var.coder_app_order
  url = join("", [
    "jetbrains://gateway/com.coder.toolbox?&workspace=",
    data.coder_workspace.me.name,
    "&owner=",
    data.coder_workspace_owner.me.name,
    "&project_path=",
    var.folder,
    "&url=",
    data.coder_workspace.me.access_url,
    "&token=",
    "$SESSION_TOKEN",
    "&ide_product_code=",
    data.coder_parameter.jetbrains_ide.value,
    "&ide_build_number=",
    local.build
  ])
}

output "identifier" {
  value = local.identifier
}

output "display_name" {
  value = local.display_name
}

output "icon" {
  value = local.icon
}

output "build_number" {
  value = local.build
}

output "url" {
  value = coder_app.jetbrains.url
}
