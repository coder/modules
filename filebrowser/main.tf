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

variable "workspace_name" {
  type = string
  default = ""
  description = "Set this and owner_name to serve filebrowser from subdirectory."
}

variable "owner_name" {
  type = string
  default = ""
  description = "Set this and workspace_name to serve filebrowser from subdirectory."
}

variable "agent_name" {
  type = string
  default = ""
  description = "The name of the main deployment. (Used to build the subpath for coder_app.)"
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

variable "share" {
  type    = string
  default = "owner"
  validation {
    condition     = var.share == "owner" || var.share == "authenticated" || var.share == "public"
    error_message = "Incorrect value. Please set either 'owner', 'authenticated', or 'public'."
  }
}

variable "order" {
  type        = number
  description = "The order determines the position of app in the UI presentation. The lowest order is shown first and apps with equal order are sorted by name (ascending order)."
  default     = null
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
    DB_PATH : var.database_path,
    WORKSPACE_NAME : var.workspace_name,
    OWNER_NAME : var.owner_name,
    AGENT_NAME : var.agent_name
    SUBDOMAIN : var.subdomain
  })
  run_on_start = true
}

resource "coder_app" "filebrowser" {
  agent_id     = var.agent_id
  slug         = "filebrowser"
  display_name = "File Browser"
  url          = "http://localhost:${var.port}"
  icon         = "https://raw.githubusercontent.com/filebrowser/logo/master/icon_raw.svg"
  subdomain    = var.subdomain
  share        = var.share
  order        = var.order
}
