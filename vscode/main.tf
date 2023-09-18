terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.11"
    }
  }
}

variable "agent_id" {
  type        = string
  description = "The ID of a Coder agent."
}

data "coder_workspace" "me" {}

resource "coder_app" "vscode" {
	agent_id = var.agent_id
	external = true
	url = join("", [
		"vscode://coder.coder-remote/open?owner=",
		data.coder_workspace.me.owner,
		"&workspace=",
		data.coder_workspace.me.name,
		"&token=",
		data.coder_workspace.me.owner_session_token,
	])
}  
