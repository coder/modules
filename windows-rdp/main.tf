terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.17"
    }
  }
}

variable "share" {
  type    = string
  default = "owner"
  validation {
    condition     = var.share == "owner" || var.share == "authenticated" || var.share == "public"
    error_message = "Incorrect value. Please set either 'owner', 'authenticated', or 'public'."
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
  icon         = "/icon/desktop.svg"

  script = templatefile("${path.module}/powershell-installation-script.tftpl", {
    admin_username = var.admin_username
    admin_password = var.admin_password

    # Wanted to have this be in the powershell template file, but Terraform
    # doesn't allow recursive calls to the templatefile function. Have to feed
    # results of the JS template replace into the powershell template
    patch_file_contents = templatefile("${path.module}/devolutions-patch.js", {
      CODER_USERNAME = var.admin_username
      CODER_PASSWORD = var.admin_password
    })
  })

  run_on_start = true
}

resource "coder_app" "windows-rdp" {
  agent_id     = var.agent_id
  share        = var.share
  slug         = "web-rdp"
  display_name = "Web RDP"
  url          = "http://localhost:7171"
  icon         = "/icon/desktop.svg"
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
  url          = "https://coder.com/docs/ides/remote-desktops#rdp-desktop"
  external     = true
}
