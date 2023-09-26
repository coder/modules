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

variable "log_path" {
  type        = string
  description = "The path to log jupyterlab to."
  default     = "/tmp/jupyterlab.log"
}

variable "port" {
  type        = number
  description = "The port to run jupyterlab on."
  default     = 19999
}

resource "coder_script" "jupyterlab" {
  agent_id     = var.agent_id
  display_name = "jupyterlab"
  icon         = "/icon/jupyter.svg"
  script = templatefile("${path.module}/run.sh", {
    LOG_PATH : var.log_path,
    PORT : var.port
  })
  run_on_start = true
}

resource "coder_app" "jupyterlab" {
  agent_id     = var.agent_id
  slug         = "jupyterlab"
  display_name = "JupyterLab"
  url          = "http://localhost:${var.port}"
  icon         = "/icon/jupyter.svg"
  subdomain    = true
  share        = "owner"
}
