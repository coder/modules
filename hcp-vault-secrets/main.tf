terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.12.4"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = ">= 0.82.0"
    }
  }
}

provider "hcp" {
  client_id     = var.client_id
  client_secret = var.client_secret
}

provider "coder" {}

variable "agent_id" {
  type        = string
  description = "The ID of a Coder agent."
}

variable "secrets_list" {
  type = list(string)
}

variable "client_id" {
  type        = string
  description = <<-EOF
  The client ID for the HCP Vault Secrets service principal. (Optional if HCP_CLIENT_ID is set as an environment variable.)
  EOF
  default     = null
  sensitive   = true
}

variable "client_secret" {
  type        = string
  description = <<-EOF
  The client secret for the HCP Vault Secrets service principal. (Optional if HCP_CLIENT_SECRET is set as an environment variable.)
  EOF
  default     = null
  sensitive   = true
}

variable "app_name" {
  type        = string
  description = "The name of the secrets app in HCP Vault Secrets"
}

data "hcp_vault_secrets_secret" "secret" {
  for_each    = toset(var.secrets_list)
  app_name    = var.app_name
  secret_name = each.value
}

resource "coder_env" "hvs_secrets" {
  for_each = data.hcp_vault_secrets_secret.secret
  agent_id = var.agent_id
  name     = each.key
  value    = each.value.secret_value
}