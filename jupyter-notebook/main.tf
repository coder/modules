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
  description = "The path to log jupyter notebook to."
  default     = "/tmp/jupyter-notebook.log"
}

variable "port" {
  type        = number
  description = "The port to run jupyter-notebook on."
  default     = 19999
}

resource "coder_script" "jupyter-notebook" {
  agent_id     = var.agent_id
  display_name = "jupyter-notebook"
  icon         = "/icon/jupyter.svg"
  script = templatefile("${path.module}/run.sh", {
    LOG_PATH : var.log_path,
    PORT : var.port
  })
  run_on_start = true
}

resource "coder_app" "jupyter-notebook" {
  agent_id     = var.agent_id
  slug         = "jupyter-notebook"
  display_name = "Jupyter Notebook"
  url          = "http://localhost:${var.port}"
  icon         = "/icon/jupyter.svg"
  subdomain    = true
  share        = "owner"
}
