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

variable "jfrog_host" {
  type        = string
  description = "JFrog instance hostname. e.g. YYY.jfrog.io"
}

variable "artifactory_access_token" {
  type        = string
  description = "The admin-level access token to use for JFrog."
}

# Configure the Artifactory provider
provider "artifactory" {
  url          = "https://${var.jfrog_host}/artifactory"
  access_token = var.artifactory_access_token
}
resource "artifactory_scoped_token" "me" {
  # This is hacky, but on terraform plan the data source gives empty strings,
  # which fails validation.
  username = length(data.coder_workspace.me.owner_email) > 0 ? data.coder_workspace.me.owner_email : "plan"
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
    JFROG_HOST : var.jfrog_host,
    ARTIFACTORY_USERNAME : data.coder_workspace.me.owner_email,
    ARTIFACTORY_ACCESS_TOKEN : artifactory_scoped_token.me.access_token,
    REPOSITORY_NPM : lookup(var.package_managers, "npm", ""),
    REPOSITORY_GO : lookup(var.package_managers, "go", ""),
    REPOSITORY_PYPI : lookup(var.package_managers, "pypi", ""),
  })
  run_on_start = true
}
