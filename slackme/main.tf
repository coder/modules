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

variable "external_provider_id" {
    type        = string
    description = "The ID of an external provider."
}

resource "coder_script" "install_slackme" {
    agent_id = var.agent_id
    display_name     = "install_slackme"
    script = <<EOF
    #!/usr/bin/env bash

    CODER_DIR=$(dirname $(which coder))
    cat > $CODER_DIR/slackme <<EOF
    ${templatefile("${path.module}/slackme.sh", {
        PROVIDER_ID: var.external_provider_id
    })}
    \EOF
    chmod +x $CODER_DIR/slackme
    EOF 
}