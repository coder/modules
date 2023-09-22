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

# variable "path" {
#     type = string
#     description = "The path to a script that will be ran on start enabling a user to personalize their workspace."
#     default = "~/personalize"
# }

resource "coder_script" "personalize" {
    agent_id = var.agent_id
    script = templatefile("${path.module}/run.sh")
    display_name = "Git Config"
    icon = "/emojis/1f58c.png"      # TODO: test if the local git icon works
    run_on_start = true
}
