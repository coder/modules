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

variable "default" {
  type        = string
  description = "The default dotfiles URI if the workspace user does not provide one."
  default     = ""
}

data "coder_parameter" "dotfiles_uri" {
  type         = "string"
  name         = "dotfiles_uri"
  display_name = "Dotfiles URL (optional)"
  default      = var.default
  description  = "Enter a URL for a [dotfiles repository](https://dotfiles.github.io) to personalize your workspace"
  mutable      = true
  icon         = "/icon/dotfiles.svg"
}

resource "coder_script" "personalize" {
  agent_id     = var.agent_id
  script       = <<-EOT
    DOTFILES_URI="${data.coder_parameter.dotfiles_uri.value}"
    if [ -n "$${DOTFILES_URI// }" ]; then
    coder dotfiles "$DOTFILES_URI" -y 2>&1 | tee -a ~/.dotfiles.log
    fi
    EOT
  display_name = "Dotfiles"
  icon         = "/icon/dotfiles.svg"
  run_on_start = true
}

output "dotfiles_uri" {
  description = "Dotfiles URI"
  value       = data.coder_parameter.dotfiles_uri.value
}

output "dotfiles_default_uri" {
  description = "Dotfiles Default URI"
  value       = var.default
}