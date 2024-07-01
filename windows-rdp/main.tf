terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.17"
    }
  }
}

variable "agent_id" {
  type        = string
  description = "The ID of a Coder agent."
}

variable "resource_id" {
  type        = string
  description = "The ID of the primary Coder resource (e.g. VM)."
}

variable "admin_username" {
  type    = string
  default = "Administrator"
}

variable "admin_password" {
  type      = string
  default   = "coderRDP!"
  sensitive = true
}

resource "coder_script" "windows-rdp" {
  agent_id     = var.agent_id
  display_name = "windows-rdp"
  icon         = "https://svgur.com/i/158F.svg" # TODO: add to Coder icons
  script = templatefile("${path.module}/./windows-installation.tftpl", {
    CODER_USERNAME : var.admin_username,
    CODER_PASSWORD : var.admin_password,
  })

  run_on_start = true
}

resource "coder_app" "windows-rdp" {
  agent_id     = var.agent_id
  slug         = "web-rdp"
  display_name = "Web RDP"
  url          = "http://localhost:7171"
  icon         = "https://svgur.com/i/158F.svg"
  subdomain    = true

  healthcheck {
    url       = "http://localhost:7171"
    interval  = 5
    threshold = 15
  }
}

resource "coder_app" "rdp-docs" {
  agent_id     = var.agent_id
  display_name = "Local RDP"
  slug         = "rdp-docs"
  icon         = "https://raw.githubusercontent.com/matifali/logos/main/windows.svg"
  url          = "https://coder.com/docs/v2/latest/ides/remote-desktops#rdp-desktop"
  external     = true
}
