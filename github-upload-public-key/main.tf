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

resource "coder_script" "github_upload_public_key" {
  agent_id = var.agent_id
  script = templatefile("${path.module}/run.sh", {
    CODER_OWNER_SESSION_TOKEN : data.coder_workspace.me.owner_session_token,
    CODER_ACCESS_URL : data.coder_workspace.me.access_url,
    GITHUB_EXTERNAL_AUTH_ID : var.external_auth_id,
  })
  display_name = "Github Upload Public Key"
  icon         = "/icon/github.svg"
  run_on_start = true
}