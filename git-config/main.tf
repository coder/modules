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

resource "coder_script" "personalize" {
    agent_id = var.agent_id
    script = templatefile("${path.module}/run.sh", {})  # TODO: maybe remove templatefile
    display_name = "Git Config"
    icon = "/emojis/1f58c.png"                          # TODO: test if the local git icon works
    run_on_start = true
}
