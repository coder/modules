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

variable "vault_auth_id" {
  type        = string
  description = "The ID of the Vault auth method to use."
  default     = "vault"
}

variable "secrets" {
  type        = map(map(string))
  description = <<EOF
  A map of secrets to write to the workspace. The key is the path of the secret in vault and the value is a map of the list of secrets and the file to write them to.
  e.g,
  {
    "secret/data/my-secret-1" = {
      "secrets" = ["username", "password"]
      "file" = "secrets.env"
    },
    "secret/data/my-secret-2" = {
      "secrets" = ["username", "password"]
      "file" = "secrets2.env"
    }
  }
  EOF 
  default     = {}
}

variable "vault_cli_version" {
  type        = string
  description = "The version of Vault to install."
  default     = "latest"
  # validate the version is in the format x.y.z or latest
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
    VAULT_TOKEN : data.coder_git_auth.vault.access_token,
    VERSION : var.vault_cli_version,
    SECRETS : jsonencode(var.secrets)
  })
  run_on_start = true
}

# TODO replace with a "coder_external_auth" data source once https://github.com/coder/coder/issues/10122 is resolved
data "coder_git_auth" "vault" {
  id = var.vault_auth_id
}
