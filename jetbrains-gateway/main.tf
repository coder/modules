terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "coder/coder"
      version = ">= 0.11"
    }
  }
}

variable "agent_id" {
  type        = string
  description = "The ID of a Coder agent."
}

variable "gateway_project_directory" {
  type        = string
  description = "The directory to open in the IDE. e.g. /home/coder/project"
}

variable "gateway_ide_product_code" {
  type        = string
  description = "The IDE product codes, comma-separated. e.g. for GoLand and WebStorm: `GO,WS` and for all: `ALL`"

  validation {
    condition = (
      lower(var.gateway_ide_product_code) == "all" ||
      alltrue([
        for code in split(",", trimspace(var.gateway_ide_product_code)) :
        contains(["IU", "IC", "PS", "WS", "PY", "PC", "CL", "GO", "DB", "RD"], trimspace(code))
      ])
    )
    error_message = "The gateway_ide_product_code must be ALL or a comma-separated list of valid product codes. https://plugins.jetbrains.com/docs/marketplace/product-codes.html"
  }
  default = "all"
}

locals {
  gateway_ides = {
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
      icon  = "/icon/idea.svg",
      name  = "IntelliJ IDEA Ultimate",
      value = jsonencode(["IU", "232.9921.47", "https://download.jetbrains.com/idea/ideaIU-2023.2.2.tar.gz"])
    },
    "IC" = {
      icon  = "/icon/idea.svg",
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
  }
}

data "coder_parameter" "jetbrains_ide" {
  type         = "list(string)"
  name         = "jetbrains_ide"
  display_name = "JetBrains IDE"
  icon         = "/icon/gateway.svg"
  mutable      = true
  default      = local.gateway_ides["GO"].value

  dynamic "option" {
    for_each = lower(var.gateway_ide_product_code) == "all" ? local.gateway_ides : { for key, value in local.gateway_ides : key => value if key == var.gateway_ide_product_code }
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
  url          = "jetbrains-gateway://connect#type=coder&workspace=${data.coder_workspace.me.name}&agent=dev&folder=${var.gateway_project_directory}&url=${data.coder_workspace.me.access_url}&token=${data.coder_workspace.me.owner_session_token}&ide_product_code=${jsondecode(data.coder_parameter.jetbrains_ide.value)[0]}&ide_build_number=${jsondecode(data.coder_parameter.jetbrains_ide.value)[1]}&ide_download_link=${jsondecode(data.coder_parameter.jetbrains_ide.value)[2]}"
  icon         = data.coder_parameter.jetbrains_ide.option[index(data.coder_parameter.jetbrains_ide.option.*.value, data.coder_parameter.jetbrains_ide.value)].icon
  external     = true
}
