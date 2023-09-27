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

variable "allow_username_change" {
  type        = bool
  description = "Allow developers to change their git username."
  default     = true
}

variable "allow_email_change" {
  type        = bool
  description = "Allow developers to change their git email."
  default     = false
}

data "coder_workspace" "me" {}

data "coder_parameter" "user_email" {
  count        = var.allow_email_change ? 1 : 0
  name         = "user_email"
  type         = "string"
  default      = data.coder_workspace.me.owner_email
  description  = "Git user.email to be used for commits"
  display_name = "Git config user.email"
  mutable      = true
}

data "coder_parameter" "username" {
  count        = var.allow_username_change ? 1 : 0
  name         = "username"
  type         = "string"
  default      = data.coder_workspace.me.owner
  description  = "Git user.name to be used for commits"
  display_name = "Git config user.name"
  mutable      = true
}

resource "coder_script" "git_config" {
  agent_id = var.agent_id
  script = templatefile("${path.module}/run.sh", {
    CODER_USERNAME = try(data.coder_parameter.username[0].value, data.coder_workspace.me.owner)
    CODER_EMAIL    = try(data.coder_parameter.user_email[0].value, data.coder_workspace.me.owner_email)
  })
  display_name = "Git Config"
  icon         = "/icon/git.svg"
  run_on_start = true
}