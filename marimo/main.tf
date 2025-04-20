terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.17"
    }
  }
}

data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}

# Add required variables for your modules and remove any unneeded variables
variable "agent_id" {
  type        = string
  description = "The ID of a Coder agent."
}

variable "log_path" {
  type        = string
  description = "The path to log marimo to."
  default     = "/tmp/marimo.log"
}

variable "port" {
  type        = number
  description = "The port to run marimo on."
  default     = 18888
}

variable "share" {
  type    = string
  default = "owner"
  validation {
    condition     = var.share == "owner" || var.share == "authenticated" || var.share == "public"
    error_message = "Incorrect value. Please set either 'owner', 'authenticated', or 'public'."
  }
}

variable "subdomain" {
  type        = bool
  description = "Determines whether marimo will be accessed via its own subdomain or whether it will be accessed via a path on Coder."
  default     = true
}

variable "order" {
  type        = number
  description = "The order determines the position of app in the UI presentation. The lowest order is shown first and apps with equal order are sorted by name (ascending order)."
  default     = null
}

resource "coder_script" "marimo" {
  agent_id     = var.agent_id
  display_name = "marimo"
  icon         = "/icon/marimo.svg"
  script = templatefile("${path.module}/run.sh", {
    LOG_PATH : var.log_path,
    PORT : var.port
    BASE_URL : var.subdomain ? "" : "/@${data.coder_workspace_owner.me.name}/${data.coder_workspace.me.name}/apps/marimo"
  })
  run_on_start = true
}

resource "coder_app" "marimo" {
  agent_id     = var.agent_id
  slug         = "marimo" # sync with the usage in URL
  display_name = "marimo"
  url          = var.subdomain ? "http://localhost:${var.port}" : "http://localhost:${var.port}/@${data.coder_workspace_owner.me.name}/${data.coder_workspace.me.name}/apps/marimo"
  icon         = "/icon/marimo.svg"
  subdomain    = var.subdomain
  share        = var.share
  order        = var.order
}