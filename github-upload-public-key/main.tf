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

variable "external_auth_id" {
  type        = string
  description = "The ID of the GitHub external auth."
  default     = "github"
}

variable "github_api_url" {
  type        = string
  description = "The URL of the GitHub instance."
  default = "https://api.github.com"
}

// Optional variables mostly for testing purposes, will normally come from data.coder_workspace.me
variable "access_url" {
  type        = string
  description = "The access URL of the workspace."
  default     = ""
}

variable "owner_session_token" {
  type        = string
  description = "The owner session token of the workspace."
  default     = ""
}

data "coder_workspace" "me" {}

resource "coder_script" "github_upload_public_key" {
  agent_id = var.agent_id
  script = templatefile("${path.module}/run.sh", {
    CODER_OWNER_SESSION_TOKEN : var.owner_session_token != "" ? var.owner_session_token : data.coder_workspace.me.owner_session_token,
    CODER_ACCESS_URL : var.access_url != "" ? var.access_url : data.coder_workspace.me.access_url,
    CODER_EXTERNAL_AUTH_ID : var.external_auth_id,
    GITHUB_API_URL : var.github_api_url,
  })
  display_name = "Github Upload Public Key"
  icon         = "/icon/github.svg"
  run_on_start = true
}