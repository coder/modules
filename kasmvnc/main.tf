terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.12"
    }
  }
}

locals {
  template_data = object({
    PORT                = var.port,
    DESKTOP_ENVIRONMENT = var.desktop_environment,
    KASM_VERSION        = var.kasm_version
    SUBDOMAIN           = tostring(var.subdomain)
  })
}

resource "coder_script" "kasm_vnc" {
  agent_id     = var.agent_id
  display_name = "KasmVNC"
  icon         = "/icon/kasmvnc.svg"
  run_on_start = true
  script       = templatefile("${path.module}/run.sh", locals.template_data)
}

resource "coder_app" "kasm_vnc" {
  agent_id     = var.agent_id
  slug         = "kasm-vnc"
  display_name = "KasmVNC"
  url          = "http://localhost:${var.port}"
  icon         = "/icon/kasmvnc.svg"
  subdomain    = var.subdomain
  share        = "owner"
  healthcheck {
    url       = "http://localhost:${var.port}/app"
    interval  = 5
    threshold = 5
  }
}
