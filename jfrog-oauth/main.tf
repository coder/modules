terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.12"
    }
  }
}

variable "jfrog_url" {
  type        = string
  description = "JFrog instance URL. e.g. https://jfrog.example.com"
}

variable "username_field" {
  type        = string
  description = "The field to use for the artifactory username. i.e. Coder username or email."
  default     = "username"
  validation {
    condition     = can(regex("^(email|username)$", var.username_field))
    error_message = "username_field must be either 'email' or 'username'"
  }
}

variable "external_auth_id" {
  type        = string
  description = "JFrog external auth ID. Default: 'jfrog'"
  default     = "jfrog"
}

variable "agent_id" {
  type        = string
  description = "The ID of a Coder agent."
}

variable "package_managers" {
  type        = map(string)
  description = <<EOF
A map of package manager names to their respective artifactory repositories.
For example:
    {
      "npm": "npm-local",
      "go": "go-local",
      "pypi": "pypi-local"
    }
EOF
}

locals {
  # The username field to use for artifactory
  username = var.username_field == "email" ? data.coder_workspace.me.owner_email : data.coder_workspace.me.owner
}

data "coder_workspace" "me" {}

data "coder_external_auth" "jfrog" {
  id = var.external_auth_id
}

resource "coder_script" "jfrog" {
  agent_id     = var.agent_id
  display_name = "jfrog"
  icon         = "/icon/jfrog.svg"
  script = templatefile("${path.module}/run.sh", {
    JFROG_URL : var.jfrog_url,
    JFROG_HOST : replace(var.jfrog_url, "https://", ""),
    ARTIFACTORY_USERNAME : local.username,
    ARTIFACTORY_EMAIL : data.coder_workspace.me.owner_email,
    ARTIFACTORY_ACCESS_TOKEN : data.coder_external_auth.jfrog.access_token,
    REPOSITORY_NPM : lookup(var.package_managers, "npm", ""),
    REPOSITORY_GO : lookup(var.package_managers, "go", ""),
    REPOSITORY_PYPI : lookup(var.package_managers, "pypi", ""),
  })
  run_on_start = true
}

output "access_token" {
  description = "value of the JFrog access token"
  value       = data.coder_external_auth.jfrog.access_token
  sensitive   = true
}

output "username" {
  description = "value of the JFrog username"
  value       = local.username
}
