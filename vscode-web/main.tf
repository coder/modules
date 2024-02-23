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

variable "port" {
  type        = number
  description = "The port to run VS Code Web on."
  default     = 13338
}

variable "display_name" {
  type        = string
  description = "The display name for the VS Code Web application."
  default     = "VS Code Web"
}

variable "slug" {
  type        = string
  description = "The slug for the VS Code Web application."
  default     = "vscode-web"
}

variable "folder" {
  type        = string
  description = "The folder to open in vscode-web."
  default     = ""
}

variable "share" {
  type    = string
  default = "owner"
  validation {
    condition     = var.share == "owner" || var.share == "authenticated" || var.share == "public"
    error_message = "Incorrect value. Please set either 'owner', 'authenticated', or 'public'."
  }
}

variable "log_path" {
  type        = string
  description = "The path to log."
  default     = "/tmp/vscode-web.log"
}

variable "install_prefix" {
  type        = string
  description = "The prefix to install vscode-web to."
  default     = "/tmp/vscode-web"
}

variable "extensions" {
  type        = list(string)
  description = "A list of extensions to install."
  default     = []
}

variable "accept_license" {
  type        = bool
  description = "Accept the VS Code Server license. https://code.visualstudio.com/license/server"
  default     = false
  validation {
    condition     = var.accept_license == true
    error_message = "You must accept the VS Code license agreement by setting accept_license=true."
  }
}

variable "telemetry_level" {
  type        = string
  description = "Set the telemetry level for VS Code Web."
  default     = "error"
  validation {
    condition     = var.telemetry_level == "off" || var.telemetry_level == "crash" || var.telemetry_level == "error" || var.telemetry_level == "all"
    error_message = "Incorrect value. Please set either 'off', 'crash', 'error', or 'all'."
  }
}

resource "coder_script" "vscode-web" {
  agent_id     = var.agent_id
  display_name = "VS Code Web"
  icon         = "/icon/code.svg"
  script = templatefile("${path.module}/run.sh", {
    PORT : var.port,
    LOG_PATH : var.log_path,
    INSTALL_PREFIX : var.install_prefix,
    EXTENSIONS : join(",", var.extensions),
    TELEMETRY_LEVEL : var.telemetry_level,
  })
  run_on_start = true
}

resource "coder_app" "vscode-web" {
  agent_id     = var.agent_id
  slug         = var.slug
  display_name = var.display_name
  url          = var.folder == "" ? "http://localhost:${var.port}" : "http://localhost:${var.port}?folder=${var.folder}"
  icon         = "/icon/code.svg"
  subdomain    = true
  share        = var.share

  healthcheck {
    url       = "http://localhost:${var.port}/healthz"
    interval  = 5
    threshold = 6
  }
}
