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

variable "order" {
  type        = number
  description = "The order determines the position of app in the UI presentation. The lowest order is shown first and apps with equal order are sorted by name (ascending order)."
  default     = null
}

variable "settings" {
  type        = map(string)
  description = "A map of settings to apply to VS Code web."
  default     = {}
}

variable "offline" {
  type        = bool
  description = "Just run VS Code Web in the background, don't fetch it from the internet."
  default     = false
}

variable "use_cached" {
  type        = bool
  description = "Uses cached copy of VS Code Web in the background, otherwise fetches it from internet."
  default     = false
}

variable "extensions_dir" {
  type        = string
  description = "Override the directory to store extensions in."
  default     = ""
}

variable "auto_install_extensions" {
  type        = bool
  description = "Automatically install recommended extensions when VS Code Web starts."
  default     = false
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
    // This is necessary otherwise the quotes are stripped!
    SETTINGS : replace(jsonencode(var.settings), "\"", "\\\""),
    OFFLINE : var.offline,
    USE_CACHED : var.use_cached,
    EXTENSIONS_DIR : var.extensions_dir,
    FOLDER : var.folder,
    AUTO_INSTALL_EXTENSIONS : var.auto_install_extensions,
  })
  run_on_start = true

  lifecycle {
    precondition {
      condition     = !var.offline || length(var.extensions) == 0
      error_message = "Offline mode does not allow extensions to be installed"
    }

    precondition {
      condition     = !var.offline || !var.use_cached
      error_message = "Offline and Use Cached can not be used together"
    }
  }
}

resource "coder_app" "vscode-web" {
  agent_id     = var.agent_id
  slug         = var.slug
  display_name = var.display_name
  url          = var.folder == "" ? "http://localhost:${var.port}" : "http://localhost:${var.port}?folder=${var.folder}"
  icon         = "/icon/code.svg"
  subdomain    = true
  share        = var.share
  order        = var.order

  healthcheck {
    url       = "http://localhost:${var.port}/healthz"
    interval  = 5
    threshold = 6
  }
}
