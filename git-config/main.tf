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
    type = string
    description = "The ID of a Coder agent."
}

# TODO: Test if the workspace owner name and email can be pulled from the module
variable "default_username" {
  type = string
  description = "The username of the Coder workspace owner."
}

variable "default_user_email" {
  type = string
  description = "The email of the Coder workspace owner."
}


data "coder_parameter" "user_email" {
  type = string
  description = "Email to store in git-config for this workspace. Leave empty to populate with workspace owner email."
  display_name = "Git config user.email"
  mutable = false
}

data "coder_parameter" "username" {
  type = string
  description = "Username to store in git-config for this workspace. Leave empty to populate with workspace owner name."
  display_name = "Git config user.name"
  mutable = false
}

resource "coder_script" "git_config" {
    agent_id = var.agent_id
    script = templatefile("${path.module}/run.sh", {
      CODER_USERNAME = data.coder_parameter.username.value != "" ? data.coder_parameter.username.value : var.username,
      CODER_EMAIL = data.coder_parameter.user_email.value != "" ? data.coder_parameter.user_email.value : var.user_email
    }) 
    display_name = "Git Config"
    icon = "/icon/git.svg" 
    run_on_start = true
}
