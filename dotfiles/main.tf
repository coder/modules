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

variable "dotfiles_uri" {
  type        = string
  description = "The URL to a dotfiles repository. (optional, when set, the user isn't prompted for their dotfiles)"

  default = null
}

variable "user" {
  type        = string
  description = "The name of the user to apply the dotfiles to. (optional, applies to the current user by default)"

  default = null
}

data "coder_parameter" "dotfiles_uri" {
  count = var.dotfiles_uri == null ? 1 : 0

  type         = "string"
  name         = "dotfiles_uri"
  display_name = "Dotfiles URL (optional)"
  default      = ""
  description  = "Enter a URL for a [dotfiles repository](https://dotfiles.github.io) to personalize your workspace"
  mutable      = true
  icon         = "/icon/dotfiles.svg"
}

locals {
  dotfiles_uri = var.dotfiles_uri != null ? var.dotfiles_uri : data.coder_parameter.dotfiles_uri[0].value
  user         = var.user != null ? var.user : ""
}

resource "coder_script" "dotfiles" {
  agent_id = var.agent_id
  script = templatefile("${path.module}/run.sh", {
    DOTFILES_URI : local.dotfiles_uri,
    DOTFILES_USER : local.user
  })
  display_name = "Dotfiles"
  icon         = "/icon/dotfiles.svg"
  run_on_start = true
}

output "dotfiles_uri" {
  description = "Dotfiles URI"
  value       = local.dotfiles_uri
}
