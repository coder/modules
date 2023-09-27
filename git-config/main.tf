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

data "coder_parameter" "user_email" {
  name         = "user_email"
  type         = "string"
  default      = data.coder_workspace.me.owner_email
  description  = "Git user.email to be used for commits"
  display_name = "Git config user.email"
  mutable      = false
}

data "coder_parameter" "username" {
  name         = "username"
  type         = "string"
  default      = data.coder_workspace.me.owner
  description  = "Git user.name to be used for commits"
  display_name = "Git config user.name"
  mutable      = false
}

data "coder_workspace" "me" {}

resource "coder_script" "git_config" {
  agent_id = var.agent_id
  script = templatefile("${path.module}/run.sh", {
    CODER_USERNAME = data.coder_parameter.username.value
    CODER_EMAIL    = data.coder_parameter.user_email.value
  })
  display_name = "Git Config"
  icon         = "/icon/git.svg"
  run_on_start = true
}
