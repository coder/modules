terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.17"
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

variable "share" {
  type    = string
  default = "owner"
  validation {
    condition     = var.share == "owner" || var.share == "authenticated" || var.share == "public"
    error_message = "Incorrect value. Please set either 'owner', 'authenticated', or 'public'."
  }
}

variable "order" {
  type        = number
  description = "The order determines the position of app in the UI presentation. The lowest order is shown first and apps with equal order are sorted by name (ascending order)."
  default     = null
}

variable "agent_name" {
  type        = string
  description = "The name of the coder_agent resource. (Only required if subdomain is false and the template uses multiple agents.)"
  default     = null
}

variable "slug" {
  type        = string
  description = "The slug of the coder_app resource."
  default     = "jupyter-notebook"
}

variable "subdomain" {
  type        = bool
  description = <<-EOT
    Determines whether the app will be accessed via it's own subdomain or whether it will be accessed via a path on Coder.
    If wildcards have not been setup by the administrator then apps with "subdomain" set to true will not be accessible.
  EOT
  default     = true
}

resource "coder_script" "jupyter-notebook" {
  agent_id     = var.agent_id
  display_name = "Jupyter Notebook"
  icon         = "/icon/jupyter.svg"
  script = templatefile("${path.module}/run.sh", {
    LOG_PATH : var.log_path,
    PORT : var.port
  })
  run_on_start = true
}

resource "coder_app" "jupyter-notebook" {
  agent_id     = var.agent_id
  slug         = var.slug
  display_name = "Jupyter Notebook"
  url          = local.url
  icon         = "/icon/jupyter.svg"
  subdomain    = true
  share        = var.share
  order        = var.order

  healthcheck {
    url       = local.healthcheck_url
    interval  = 5
    threshold = 6
  }
}
locals {
  server_base_path = var.subdomain ? "" : format(var.agent_name != null ? "/@%s/%s.%s/apps/%s" : "/@%s/%s/apps/%s", data.coder_workspace_owner.me.name, data.coder_workspace.me.name, var.agent_name, var.slug)
  url              = "http://localhost:${var.port}${local.server_base_path}"
  healthcheck_url  = "http://localhost:${var.port}${local.server_base_path}/api"
}
