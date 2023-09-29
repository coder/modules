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

variable "coder_user_token" {
  type        = string
  description = "Coder user token for authentication. Replace with second agent?"
}

variable "coder_deployment_url" {
  type        = string
  description = "Coder Deployment URL,"
}


resource "coder_script" "personalize" {
  agent_id = var.agent_id
  script = templatefile("${path.module}/run.sh", {
    CODER_USER_TOKEN : var.coder_user_token,
    CODER_DEPLOYMENT_URL : var.coder_deployment_url
  })
  display_name       = "Personalize"
  icon               = "/icon/personalize.svg"
  log_path           = var.log_path
  run_on_start       = true
  start_blocks_login = true
}
