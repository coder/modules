terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.23"
    }
  }
}

variable "agent_id" {
  type        = string
  description = "The ID of a Coder agent."
}

variable "folder" {
  type        = string
  description = "The folder to open in Windsurf IDE."
  default     = ""
}

variable "open_recent" {
  type        = bool
  description = "Open the most recent workspace or folder. Falls back to the folder if there is no recent workspace or folder to open."
  default     = false
}

variable "order" {
  type        = number
  description = "The order determines the position of app in the UI presentation. The lowest order is shown first and apps with equal order are sorted by name (ascending order)."
  default     = null
}

data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}

resource "coder_app" "windsurf" {
  agent_id     = var.agent_id
  external     = true
  icon         = "/icon/windsurf.svg"
  slug         = "windsurf"
  display_name = "Windsurf IDE"
  order        = var.order
  url = join("", [
    "windsurf://coder.coder-remote/open",
    "?owner=",
    data.coder_workspace_owner.me.name,
    "&workspace=",
    data.coder_workspace.me.name,
    var.folder != "" ? join("", ["&folder=", var.folder]) : "",
    var.open_recent ? "&openRecent" : "",
    "&url=",
    data.coder_workspace.me.access_url,
    "&token=$SESSION_TOKEN",
  ])
}

output "windsurf_url" {
  value       = coder_app.windsurf.url
  description = "Windsurf IDE Desktop URL."
}