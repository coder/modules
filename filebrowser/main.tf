terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.12"
    }
  }
}

variable "agent_id" {
  type        = string
  description = "The ID of a Coder agent."
}

variable "database_path" {
  type        = string
  description = "The path to the filebrowser database."
  default     = "filebrowser.db"
  validation {
    # Ensures path leads to */filebrowser.db
    condition     = can(regex(".*filebrowser\\.db$", var.database_path))
    error_message = "The database_path must end with 'filebrowser.db'."
  }
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
  description = "--root value for filebrowser."
  default     = "~"
}

resource "coder_script" "filebrowser" {
  agent_id     = var.agent_id
  display_name = "File Browser"
  icon         = "https://raw.githubusercontent.com/filebrowser/logo/master/icon_raw.svg"
  script = templatefile("${path.module}/run.sh", {
    LOG_PATH : var.log_path,
    PORT : var.port,
    FOLDER : var.folder,
    LOG_PATH : var.log_path,
    DB_PATH : var.database_path
  })
  run_on_start = true
}

resource "coder_app" "filebrowser" {
  agent_id     = var.agent_id
  slug         = "filebrowser"
  display_name = "File Browser"
  url          = "http://localhost:${var.port}"
  icon         = "https://raw.githubusercontent.com/filebrowser/logo/master/icon_raw.svg"
  subdomain    = true
  share        = "owner"
}
