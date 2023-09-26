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
  username = length(local.artifactory_username) > 0 ? local.artifactory_username : "plan"
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
resource "coder_script" "jfrog" {
  agent_id     = var.agent_id
  display_name = "jfrog"
  icon         = local.icon_url
  script = templatefile("${path.module}/run.sh", {
    JFROG_HOST : var.jfrog_host,
    ARTIFACTORY_USERNAME : artifactory_scoped_token.me.username,
    ARTIFACTORY_ACCESS_TOKEN : artifactory_scoped_token.me.token,
    REPOSITORY_NPM : lookup(var.package_managers, "npm", ""),
    REPOSITORY_GO : lookup(var.package_managers, "go", ""),
    REPOSITORY_PYPI : lookup(var.package_managers, "pypi", ""),
  })
  run_on_start = true
}

resource "coder_app" "jfrog" {
  agent_id     = var.agent_id
  slug         = "jfrog"
  display_name = "jfrog"
  url          = "http://localhost:${var.port}"
  icon         = loocal.icon_url
  subdomain    = false
  share        = "owner"

  # Remove if the app does not have a healthcheck endpoint
  healthcheck {
    url       = "http://localhost:${var.port}/healthz"
    interval  = 5
    threshold = 6
  }
}

data "coder_parameter" "jfrog" {
  type         = "list(string)"
  name         = "jfrog"
  display_name = "jfrog"
  icon         = local.icon_url
  mutable      = var.mutable
  default      = local.options["Option 1"]["value"]

  dynamic "option" {
    for_each = local.options
    content {
      icon  = option.value.icon
      name  = option.value.name
      value = option.value.value
    }
  }
}

