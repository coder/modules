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
  default     = false
}

variable "allow_email_change" {
  type        = bool
  description = "Allow developers to change their git email."
  default     = false
}

# variable "default_username_source" {
#   type        = string
#   description = "Default source to use for git-config user.name."
# }

# variable "default_email_source" {
#   type        = string
#   description = "Default source to use for git-config user.email."
# }

data "coder_workspace" "me" {}

data "coder_parameter" "user_email" {
  count        = var.allow_email_change ? 1 : 0
  name         = "user_email"
  type         = "string"
  default      = "NONE" #var.default_email_source
  description  = "Git user.email to be used for commits"
  display_name = "Git config user.email"
  mutable      = true
}

data "coder_parameter" "username" {
  count        = var.allow_username_change ? 1 : 0
  name         = "username"
  type         = "string"
  default      = "NONE" #var.default_username_source
  description  = "Git user.name to be used for commits"
  display_name = "Git config user.name"
  mutable      = true
}

resource "coder_script" "git_config" {
  agent_id = var.agent_id
  script = templatefile("${path.module}/run.sh", {
    GIT_USERNAME = data.coder_workspace.me.owner # try(data.coder_parameter.username[0].value, var.default_username_source)
    GIT_EMAIL    = data.coder_workspace.me.owner_email # try(data.coder_parameter.user_email[0].value, var.default_email_source)
  })
  display_name = "Git Config"
  icon         = "/icon/git.svg"
  run_on_start = true
}


# last implementation
#     GIT_USERNAME = try(data.coder_parameter.username[0].value, var.default_username_source)
#     GIT_EMAIL    = try(data.coder_parameter.user_email[0].value, var.default_email_source)

# Old implementation, saving for testing
    # GIT_USERNAME = try(data.coder_parameter.username[0].value, data.coder_workspace.git_config.owner)
    # GIT_EMAIL    = try(data.coder_parameter.user_email[0].value, data.coder_workspace.git_config.owner_email)