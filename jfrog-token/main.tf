terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.12.4"
    }
    artifactory = {
      source  = "registry.terraform.io/jfrog/artifactory"
      version = "~> 10.0.2"
    }
  }
}

variable "jfrog_url" {
  type        = string
  description = "JFrog instance URL. e.g. https://myartifactory.jfrog.io"
  # ensue the URL is HTTPS or HTTP
  validation {
    condition     = can(regex("^(https|http)://", var.jfrog_url))
    error_message = "jfrog_url must be a valid URL starting with either 'https://' or 'http://'"
  }
}

variable "artifactory_access_token" {
  type        = string
  description = "The admin-level access token to use for JFrog."
}

variable "check_license" {
  type        = bool
  description = "Toggle for pre-flight checking of Artifactory license. Default to `true`."
  default     = true
}

variable "refreshable" {
  type        = bool
  description = "Is this token refreshable? Default is `false`."
  default     = false
}

variable "expires_in" {
  type        = number
  description = "The amount of time, in seconds, it would take for the token to expire."
  default     = null
}

variable "username_field" {
  type        = string
  description = "The field to use for the artifactory username. Default `username`."
  default     = "username"
  validation {
    condition     = can(regex("^(email|username)$", var.username_field))
    error_message = "username_field must be either 'email' or 'username'"
  }
}

variable "agent_id" {
  type        = string
  description = "The ID of a Coder agent."
}

variable "configure_code_server" {
  type        = bool
  description = "Whether to configure code-server to use JFrog."
  default     = false
}

variable "package_managers" {
  type        = map(string)
  description = <<EOF
A map of package manager names to their respective artifactory repositories.
For example:
    {
      "npm": "YOUR_NPM_REPO_KEY",
      "go": "YOUR_GO_REPO_KEY",
      "pypi": "YOUR_PYPI_REPO_KEY",
      "docker": "YOUR_DOCKER_REPO_KEY"
    }
EOF
}

locals {
  # The username field to use for artifactory
  username   = var.username_field == "email" ? data.coder_workspace.me.owner_email : data.coder_workspace.me.owner
  jfrog_host = replace(var.jfrog_url, "https://", "")
}

# Configure the Artifactory provider
provider "artifactory" {
  url           = join("/", [var.jfrog_url, "artifactory"])
  access_token  = var.artifactory_access_token
  check_license = var.check_license
}

resource "artifactory_scoped_token" "me" {
  # This is hacky, but on terraform plan the data source gives empty strings,
  # which fails validation.
  username    = length(local.username) > 0 ? local.username : "dummy"
  scopes      = ["applied-permissions/user"]
  refreshable = var.refreshable
  expires_in  = var.expires_in
}

data "coder_workspace" "me" {}

resource "coder_script" "jfrog" {
  agent_id     = var.agent_id
  display_name = "jfrog"
  icon         = "/icon/jfrog.svg"
  script = templatefile("${path.module}/run.sh", {
    JFROG_URL : var.jfrog_url,
    JFROG_HOST : local.jfrog_host,
    ARTIFACTORY_USERNAME : local.username,
    ARTIFACTORY_EMAIL : data.coder_workspace.me.owner_email,
    ARTIFACTORY_ACCESS_TOKEN : artifactory_scoped_token.me.access_token,
    CONFIGURE_CODE_SERVER : var.configure_code_server,
    REPOSITORY_NPM : lookup(var.package_managers, "npm", ""),
    REPOSITORY_GO : lookup(var.package_managers, "go", ""),
    REPOSITORY_PYPI : lookup(var.package_managers, "pypi", ""),
    REPOSITORY_DOCKER : lookup(var.package_managers, "docker", ""),
  })
  run_on_start = true
}

resource "coder_env" "jfrog_ide_url" {
  count    = var.configure_code_server ? 1 : 0
  agent_id = var.agent_id
  name     = "JFROG_IDE_URL"
  value    = var.jfrog_url
}

resource "coder_env" "jfrog_ide_access_token" {
  count    = var.configure_code_server ? 1 : 0
  agent_id = var.agent_id
  name     = "JFROG_IDE_ACCESS_TOKEN"
  value    = artifactory_scoped_token.me.access_token
}

resource "coder_env" "jfrog_ide_store_connection" {
  count    = var.configure_code_server ? 1 : 0
  agent_id = var.agent_id
  name     = "JFROG_IDE_STORE_CONNECTION"
  value    = true
}

resource "coder_env" "goproxy" {
  count    = lookup(var.package_managers, "go", "") == "" ? 0 : 1
  agent_id = var.agent_id
  name     = "GOPROXY"
  value    = "https://${local.username}:${artifactory_scoped_token.me.access_token}@${local.jfrog_host}/artifactory/api/go/${lookup(var.package_managers, "go", "")}"
}

output "access_token" {
  description = "value of the JFrog access token"
  value       = artifactory_scoped_token.me.access_token
  sensitive   = true
}

output "username" {
  description = "value of the JFrog username"
  value       = local.username
}
