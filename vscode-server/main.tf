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
  description = "The port to run VS Code Wbe on."
  default     = 13338
}

variable "folder" {
  type        = string
  description = "The folder to open in vscode-server."
  default     = ""
}

variable "log_path" {
  type        = string
  description = "The path to log."
  default     = "/tmp/vscode-server.log"
}

variable "telemetry" {
  type        = string
  description = "Telemetry options for vscode-server. Valid values are 'off', 'crash', 'error' or 'all'."
  default     = "crash"
  validation {
    condition = var.telemetry == "off" || var.telemetry == "crash" || var.telemetry == "error" || var.telemetry == "all"
  }
}

variable "install_dir" {
  type        = string
  description = "The directory to install VS Code Server"
  default     = "/tmp/vscode-server"
}

variable "accept_license" {
  type        = bool
  description = "Accept the VS Code license. https://code.visualstudio.com/license"
  default     = false
  validation {
    condition     = var.accept_license == true
    error_message = "You must accept the VS Code license agreement by setting accept_license=true."
  }
}

variable "custom_version" {
  type        = string
  description = "The version of VS Code to install."
  default     = "latest"
}

resource "coder_script" "vscode-server" {
  agent_id     = var.agent_id
  display_name = "vscode-server"
  icon         = "/icon/code.svg"
  script = templatefile("${path.module}/run.sh", {
    PORT : var.port,
    LOG_PATH : var.log_path,
    VERSION : var.custom_version,
    INSTALL_DIR : var.install_dir,
  })
  run_on_start = true
}

resource "coder_app" "vscode-server" {
  agent_id     = var.agent_id
  slug         = "vscode-server"
  display_name = "VS Code Server"
  url          = var.folder == "" ? "http://localhost:${var.port}" : "http://localhost:${var.port}/${var.folder}"
  icon         = "/icon/code.svg"
  subdomain    = true
  share        = "owner"

  healthcheck {
    url       = "http://localhost:${var.port}/healthz"
    interval  = 5
    threshold = 6
  }
}
