terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.12"
    }
  }
}

locals {
  icon_url = "https://raw.githubusercontent.com/coder/modules/main/.icons/git.svg"
}

variable "agent_id" {
  type        = string
  description = "The ID of a Coder agent."
}

resource "coder_script" "git-commit-signing" {
  display_name = "Git commit signing"
  icon         = local.icon_url

  script       = file("${path.module}/run.sh")
  run_on_start = true

  agent_id = var.agent_id
}
