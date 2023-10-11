terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.12"
    }
  }
}

# Add required variables for your modules and remove any unneeded variables
variable "agent_id" {
  type        = string
  description = "The ID of a Coder agent."
}

variable "vault_addr" {
  type        = string
  description = "The address of the Vault server."
}

variable "auth_provider_id" {
  type        = string
  description = "The ID of the Vault auth method to use."
  default     = "vault"
}

variable "vault_cli_version" {
  type        = string
  description = "The version of Vault to install."
  default     = "latest"
  validation {
    condition     = can(regex("^(latest|[0-9]+\\.[0-9]+\\.[0-9]+)$", var.vault_cli_version))
    error_message = "Vault version must be in the format 0.0.0 or latest"
  }
}

resource "coder_script" "vault" {
  agent_id     = var.agent_id
  display_name = "vault"
  icon         = "/icon/vault.svg"
  script = templatefile("${path.module}/run.sh", {
    VAULT_ADDR : var.vault_addr,
    PROVIDER_ID : var.auth_provider_id,
    VERSION : var.vault_cli_version,
  })
  run_on_start = true
}
