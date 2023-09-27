terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.12"
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
  description = "The path to log filebrowser to."
  default     = "/tmp/filebrowser.log"
}

variable "port" {
  type        = number
  description = "The port to run filebrowser on."
  default     = 13339
}

variable "folder" {
  type        = string
  description = "The folder to serve."
  default     = "~"
}

resource "coder_script" "filebrowser" {
  agent_id     = var.agent_id
  display_name = "filebrowser"
  icon         = "https://raw.githubusercontent.com/filebrowser/logo/master/icon_raw.svg"
  script = templatefile("${path.module}/run.sh", {
    LOG_PATH : var.log_path,
    PORT : var.port,
    FOLDER : var.folder,
  })
  run_on_start = true
}

resource "coder_app" "filebrowser" {
  agent_id     = var.agent_id
  slug         = "filebrowser"
  display_name = "filebrowser"
  url          = "http://localhost:${var.port}"
  icon         = "https://raw.githubusercontent.com/filebrowser/logo/master/icon_raw.svg"
  subdomain    = false
  share        = "owner"

  # Remove if the app does not have a healthcheck endpoint
  healthcheck {
    url       = "http://localhost:${var.port}/healthz"
    interval  = 5
    threshold = 6
  }
}
