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

variable "username" {
  type = string
  description = "The username of the Coder workspace owner."
}

variable "user_email" {
  type = string
  description = "The email of the Coder workspace owner."
}

resource "coder_script" "git_config" {
    agent_id = var.agent_id
    script = templatefile("${path.module}/run.sh", {
      CODER_USERNAME = var.username,
      CODER_EMAIL = var.user_email
    }) 
    display_name = "Git Config"
    icon = "/icon/git.svg" 
    run_on_start = true
}
