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
  description = "Agent name."
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
  }
  validation {
    condition = (
      alltrue([
        for code in var.jetbrains_ide_versions : contains(["IU", "PS", "WS", "PY", "CL", "GO", "RM"], code)
      ])
    )
    error_message = "The jetbrains_ide_versions must contain a map of valid product codes. Valid product codes are ${join(",", ["IU", "PS", "WS", "PY", "CL", "GO", "RM"])}."
  }
}

variable "jetbrains_ides" {
  type        = list(string)
  description = "The list of IDE product codes."
  default     = ["IU", "PS", "WS", "PY", "CL", "GO", "RM"]
  validation {
    condition = (
      alltrue([
        for code in var.jetbrains_ides : contains(["IU", "PS", "WS", "PY", "CL", "GO", "RM"], code)
      ])
    )
    error_message = "The jetbrains_ides must be a list of valid product codes. Valid product codes are ${join(",", ["IU", "PS", "WS", "PY", "CL", "GO", "RM"])}."
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
      value = jsonencode(["GO", var.jetbrains_ide_versions["GO"].build_number, "https://download.jetbrains.com/go/goland-${var.jetbrains_ide_versions["GO"].version}.tar.gz"])
    },
    "WS" = {
      icon  = "/icon/webstorm.svg",
      name  = "WebStorm",
      value = jsonencode(["WS", var.jetbrains_ide_versions["WS"].build_number, "https://download.jetbrains.com/webstorm/WebStorm-${var.jetbrains_ide_versions["WS"].version}.tar.gz"])
    },
    "IU" = {
      icon  = "/icon/intellij.svg",
      name  = "IntelliJ IDEA Ultimate",
      value = jsonencode(["IU", var.jetbrains_ide_versions["IU"].build_number, "https://download.jetbrains.com/idea/ideaIU-${var.jetbrains_ide_versions["IU"].version}.tar.gz"])
    },
    "PY" = {
      icon  = "/icon/pycharm.svg",
      name  = "PyCharm Professional",
      value = jsonencode(["PY", var.jetbrains_ide_versions["PY"].build_number, "https://download.jetbrains.com/python/pycharm-professional-${var.jetbrains_ide_versions["PY"].version}.tar.gz"])
    },
    "CL" = {
      icon  = "/icon/clion.svg",
      name  = "CLion",
      value = jsonencode(["CL", var.jetbrains_ide_versions["CL"].build_number, "https://download.jetbrains.com/cpp/CLion-${var.jetbrains_ide_versions["CL"].version}.tar.gz"])
    },
    "PS" = {
      icon  = "/icon/phpstorm.svg",
      name  = "PhpStorm",
      value = jsonencode(["PS", var.jetbrains_ide_versions["PS"].build_number, "https://download.jetbrains.com/webide/PhpStorm-${var.jetbrains_ide_versions["PS"].version}.tar.gz"])
    },
    "RM" = {
      icon  = "/icon/rubymine.svg",
      name  = "RubyMine",
      value = jsonencode(["RM", var.jetbrains_ide_versions["RM"].build_number, "https://download.jetbrains.com/ruby/RubyMine-${var.jetbrains_ide_versions["RM"].version}.tar.gz"])
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
  default = contains(var.jetbrains_ides, var.default) ? var.default : null

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
