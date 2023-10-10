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

variable "folder" {
  type        = string
  description = "The folder to open in VS Code."
  default     = ""
}

data "coder_workspace" "me" {}

resource "coder_app" "vscode" {
  agent_id     = var.agent_id
  external     = true
  icon         = "/icon/code.svg"
  slug         = "vscode"
  display_name = "VS Code Desktop"
  url = var.folder != "" ? join("", [
    "vscode://coder.coder-remote/open?owner=",
    data.coder_workspace.me.owner,
    "&workspace=",
    data.coder_workspace.me.name,
    "&folder=",
    var.folder,
    "&token=$SESSION_TOKEN",
    ]) : join("", [
    "vscode://coder.coder-remote/open?owner=",
    data.coder_workspace.me.owner,
    "&workspace=",
    data.coder_workspace.me.name,
    "&token=$SESSION_TOKEN",
  ])
}

output "vscode_url" {
  value       = coder_app.vscode.url
  description = "VS Code Desktop URL."
}
