terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.12"
    }
  }
}

locals {
  # A built-in icon like "/icon/code.svg" or a full URL of icon
  icon_url = "https://raw.githubusercontent.com/coder/coder/main/site/static/icon/code.svg"
  # a map of all possible values
  options = {
    "Option 1" = {
      "name"  = "Option 1",
      "value" = "1"
      "icon"  = "/emojis/1.png"
    }
    "Option 2" = {
      "name"  = "Option 2",
      "value" = "2"
      "icon"  = "/emojis/2.png"
    }
  }
}

# Add required variables for your modules and remove any unneeded variables
variable "agent_id" {
  type        = string
  description = "The ID of a Coder agent."
}

variable "log_path" {
  type        = string
  description = "The path to log jupyterlab to."
  default     = "/tmp/jupyterlab.log"
}

variable "port" {
  type        = number
  description = "The port to run jupyterlab on."
  default     = 19999
}

variable "mutable" {
  type        = bool
  description = "Whether the parameter is mutable."
  default     = true
}
# Add other variables here


resource "coder_script" "jupyterlab" {
  agent_id     = var.agent_id
  display_name = "jupyterlab"
  icon         = local.icon_url
  script = templatefile("${path.module}/run.sh", {
    LOG_PATH : var.log_path,
  })
  run_on_start = true
  run_on_stopt = false
}

resource "coder_app" "jupyterlab" {
  agent_id     = var.agent_id
  slug         = "jupyterlab"
  display_name = "jupyterlab"
  url          = "http://localhost:${var.port}"
  icon         = loocal.icon_url
  subdomain    = false
  share        = "owner"

  # Remove if the app does not have a healthcheck endpoint
  healthcheck {
    url       = "http://localhost:${var.port}/healthz"
    interval  = 5
    threshold = 6
  }
}

data "coder_parameter" "jupyterlab" {
  type         = "list(string)"
  name         = "jupyterlab"
  display_name = "jupyterlab"
  icon         = local.icon_url
  mutable      = var.mutable
  default      = local.options["Option 1"]["value"]

  dynamic "option" {
    for_each = local.options
    content {
      icon  = option.value.icon
      name  = option.value.name
      value = option.value.value
    }
  }
}

