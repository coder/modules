terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.14.2"
    }
  }
}

variable "agent_id" {
  type        = string
  description = "The ID of a Coder agent."
}

variable "extensions" {
  type        = list(string)
  description = "A list of extensions to install."
  default     = []
}

variable "port" {
  type        = number
  description = "The port to run code-server on."
  default     = 13337
}

variable "display_name" {
  type        = string
  description = "The display name for the code-server application."
  default     = "code-server"
}

variable "slug" {
  type        = string
  description = "The slug for the code-server application."
  default     = "code-server"
}

variable "settings" {
  type        = map(string)
  description = "A map of settings to apply to code-server."
  default     = {}
}

variable "folder" {
  type        = string
  description = "The folder to open in code-server."
  default     = ""
}

variable "install_prefix" {
  type        = string
  description = "The prefix to install code-server to."
  default     = "/tmp/code-server"
}

variable "log_path" {
  type        = string
  description = "The path to log code-server to."
  default     = "/tmp/code-server.log"
}

variable "install_version" {
  type        = string
  description = "The version of code-server to install."
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

variable "order" {
  type        = number
  description = "The order determines the position of app in the UI presentation. The lowest order is shown first and apps with equal order are sorted by name (ascending order)."
  default     = null
}

resource "coder_script" "code-server" {
  agent_id     = var.agent_id
  display_name = "code-server"
  icon         = "/icon/code.svg"
  script = templatefile("${path.module}/run.sh", {
    VERSION : var.install_version,
    EXTENSIONS : join(",", var.extensions),
    PORT : var.port,
    LOG_PATH : var.log_path,
    INSTALL_PREFIX : var.install_prefix,
    // This is necessary otherwise the quotes are stripped!
    SETTINGS : replace(jsonencode(var.settings), "\"", "\\\""),
  })
  run_on_start = true
}

resource "coder_app" "code-server" {
  agent_id     = var.agent_id
  slug         = var.slug
  display_name = var.display_name
  url          = "http://localhost:${var.port}/${var.folder != "" ? "?folder=${urlencode(var.folder)}" : ""}"
  icon         = "/icon/code.svg"
  subdomain    = false
  share        = var.share
  order        = var.order

  healthcheck {
    url       = "http://localhost:${var.port}/healthz"
    interval  = 5
    threshold = 6
  }
}
