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

variable "port" {
  type        = number
  description = "The port to run KasmVNC on."
  default     = 6800
}

variable "kasm_version" {
  type        = string
  description = "Version of KasmVNC to install."
  default     = "1.3.1"
}

variable "wait_for_script" {
  type        = string
  description = "The script to wait for before running the KasmVNC script."
  default     = ""
}

resource "coder_script" "kasm_vnc" {
  agent_id     = var.agent_id
  display_name = "KasmVNC"
  icon         = "/icon/kasmvnc.svg"
  script = templatefile("${path.module}/run.sh", {
    PORT : var.port,
    WAIT_FOR_SCRIPT : var.wait_for_script,
    VERSION : var.kasm_version
  })
  run_on_start = true
}

resource "coder_app" "kasm_vnc" {
  agent_id     = var.agent_id
  slug         = "kasm-vnc"
  display_name = "kasmVNC"
  url          = "http://localhost:${var.port}"
  icon         = "/icon/kasmvnc.svg"
  subdomain    = true
  share        = "owner"
  healthcheck {
    url       = "http://localhost:${var.port}/app"
    interval  = 5
    threshold = 5
  }
}
