terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.12"
    }
    artifactory = {
      source  = "registry.terraform.io/jfrog/artifactory"
      version = "~> 8.4.0"
    }
  }
}

variable "jfrog_url" {
  type        = string
  description = "JFrog instance URL. e.g. https://YYY.jfrog.io"
}

variable "artifactory_access_token" {
  type        = string
  description = "The admin-level access token to use for JFrog."
}

variable "username_field" {
  type        = string
  description = "The field to use for the artifactory username. i.e. Coder username or email."
  default     = "email"
  validation {
    condition     = can(regex("^(email|username)$", var.username_field))
    error_message = "username_field must be either 'email' or 'username'"
  }
}

variable "auth_method" {
  type        = string
  description = "The authentication method to use for JFrog."
  default     = "access_token"
  validation {
    condition     = can(regex("^(access_token|oauth)$", var.auth_method))
    error_message = "auth_method must be either 'access_token' or 'oauth'"
  }
}

variable "external_auth_id" {
  type        = string
  description = "JFrog external auth ID. Default: 'jfrog'"
  default     = "jfrog"
}
locals {
  # The username field to use for artifactory
  username     = var.username_field == "email" ? data.coder_workspace.me.owner_email : data.coder_workspace.me.username
  access_token = var.auth_method == "access_token" ? artifactory_scoped_token.me.access_token : data.coder_external_auth.jfrog.access_token
}
# Configure the Artifactory provider
provider "artifactory" {
  url          = join("/", [var.jfrog_url, "artifactory"])
  access_token = var.artifactory_access_token == "" ? null : var.artifactory_access_token
}
resource "artifactory_scoped_token" "me" {
  # This is hacky, but on terraform plan the data source gives empty strings,
  # which fails validation.
  count       = var.artifactory_access_token == "" ? 0 : 1
  username    = length(local.username) > 0 ? local.username : "plan"
  scopes      = ["applied-permissions/user"]
  refreshable = true
}

data "coder_external_auth" "jfrog" {
  id = var.external_auth_id
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

data "coder_workspace" "me" {}

resource "coder_script" "jfrog" {
  agent_id     = var.agent_id
  display_name = "jfrog"
  icon         = "/icon/jfrog.svg"
  script = templatefile("${path.module}/run.sh", {
    JFROG_URL : var.jfrog_url,
    JFROG_HOST : replace(var.jfrog_url, "https://", ""),
    ARTIFACTORY_USERNAME : local.username,
    ARTIFACTORY_ACCESS_TOKEN : local.access_token,
    REPOSITORY_NPM : lookup(var.package_managers, "npm", ""),
    REPOSITORY_GO : lookup(var.package_managers, "go", ""),
    REPOSITORY_PYPI : lookup(var.package_managers, "pypi", ""),
  })
  run_on_start = true
}
