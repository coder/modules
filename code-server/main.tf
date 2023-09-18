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
    type = string
    description = "The ID of a Coder agent."
}

variable "extensions" {
    type = list(string)
    description = "A list of extensions to install."
}

variable "port" {
    type = number
    description = "The port to run code-server on."
    default = 13337
}

variable "settings" {
    type = map(string)
    description = "A map of settings to apply to code-server."
}

data "http" "code-server-install" {
    url = "https://raw.githubusercontent.com/coder/code-server/main/install.sh"
}

resource "coder_script" "code-server" {
    agent_id = var.agent_id
    script = data.http.code-server-install.body
    run_on_start = true
}
