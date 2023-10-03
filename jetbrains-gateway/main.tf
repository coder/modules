terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.11"
    }
  }
}

variable "agent_id" {
  type        = string
  description = "The ID of a Coder agent."
}

variable "agent_name" {
  type        = string
  description = "The name of a Coder agent."
}

variable "folder" {
  type        = string
  description = "The directory to open in the IDE. e.g. /home/coder/project"
}

variable "default" {
  default     = ""
  type        = string
  description = "Default IDE"
}

variable "jetbrains_ides" {
  type        = list(string)
  description = "The list of IDE product codes."
  validation {
    condition = (
      alltrue([
        for code in var.jetbrains_ides : contains(["IU", "IC", "PS", "WS", "PY", "PC", "CL", "GO", "DB", "RD", "RM"], code)
      ])
    )
    error_message = "The jetbrains_ides must be a list of valid product codes. Valid product codes are: IU, IC, PS, WS, PY, PC, CL, GO, DB, RD, RM."
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
      icon  = "/icon/goland.svg",
      name  = "GoLand",
      value = jsonencode(["GO", "232.9921.53", "https://download.jetbrains.com/go/goland-2023.2.2.tar.gz"])
    },
    "WS" = {
      icon  = "/icon/webstorm.svg",
      name  = "WebStorm",
      value = jsonencode(["WS", "232.9921.42", "https://download.jetbrains.com/webstorm/WebStorm-2023.2.2.tar.gz"])
    },
    "IU" = {
      icon  = "/icon/intellij.svg",
      name  = "IntelliJ IDEA Ultimate",
      value = jsonencode(["IU", "232.9921.47", "https://download.jetbrains.com/idea/ideaIU-2023.2.2.tar.gz"])
    },
    "IC" = {
      icon  = "/icon/intellij.svg",
      name  = "IntelliJ IDEA Community",
      value = jsonencode(["IC", "232.9921.47", "https://download.jetbrains.com/idea/ideaIC-2023.2.2.tar.gz"])
    },
    "PY" = {
      icon  = "/icon/pycharm.svg",
      name  = "PyCharm Professional",
      value = jsonencode(["PY", "232.9559.58", "https://download.jetbrains.com/python/pycharm-professional-2023.2.1.tar.gz"])
    },
    "PC" = {
      icon  = "/icon/pycharm.svg",
      name  = "PyCharm Community",
      value = jsonencode(["PC", "232.9559.58", "https://download.jetbrains.com/python/pycharm-community-2023.2.1.tar.gz"])
    },
    "RD" = {
      icon  = "/icon/rider.svg",
      name  = "Rider",
      value = jsonencode(["RD", "232.9559.61", "https://download.jetbrains.com/rider/JetBrains.Rider-2023.2.1.tar.gz"])
    }
    "CL" = {
      icon  = "/icon/clion.svg",
      name  = "CLion",
      value = jsonencode(["CL", "232.9921.42", "https://download.jetbrains.com/cpp/CLion-2023.2.2.tar.gz"])
    },
    "DB" = {
      icon  = "/icon/datagrip.svg",
      name  = "DataGrip",
      value = jsonencode(["DB", "232.9559.28", "https://download.jetbrains.com/datagrip/datagrip-2023.2.1.tar.gz"])
    },
    "PS" = {
      icon  = "/icon/phpstorm.svg",
      name  = "PhpStorm",
      value = jsonencode(["PS", "232.9559.64", "https://download.jetbrains.com/webide/PhpStorm-2023.2.1.tar.gz"])
    },
    "RM" = {
      icon  = "/icon/rubymine.svg",
      name  = "RubyMine",
      value = jsonencode(["RM", "232.9921.48", "https://download.jetbrains.com/ruby/RubyMine-2023.2.2.tar.gz"])
    }
  }
}

data "coder_parameter" "jetbrains_ide" {
  type         = "list(string)"
  name         = "jetbrains_ide"
  display_name = "JetBrains IDE"
  icon         = "/icon/gateway.svg"
  mutable      = true
  # check if default is in the jet_brains_ides list and if it is not empty or null otherwise set it to null
  default = var.default != null && var.default != "" && contains(var.jetbrains_ides, var.default) ? local.jetbrains_ides[var.default].value : local.jetbrains_ides[var.jetbrains_ides[0]].value

  dynamic "option" {
    for_each = { for key, value in local.jetbrains_ides : key => value if contains(var.jetbrains_ides, key) }
    content {
      icon  = option.value.icon
      name  = option.value.name
      value = option.value.value
    }
  }
}

data "coder_workspace" "me" {}

resource "coder_app" "gateway" {
  agent_id     = var.agent_id
  display_name = data.coder_parameter.jetbrains_ide.option[index(data.coder_parameter.jetbrains_ide.option.*.value, data.coder_parameter.jetbrains_ide.value)].name
  slug         = "gateway"
  icon         = data.coder_parameter.jetbrains_ide.option[index(data.coder_parameter.jetbrains_ide.option.*.value, data.coder_parameter.jetbrains_ide.value)].icon
  external     = true
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
    jsondecode(data.coder_parameter.jetbrains_ide.value)[0],
    "&ide_build_number=",
    jsondecode(data.coder_parameter.jetbrains_ide.value)[1],
    "&ide_download_link=",
    jsondecode(data.coder_parameter.jetbrains_ide.value)[2],
  ])
}

output "jetbrains_ides" {
  value = data.coder_parameter.jetbrains_ide.value
}
