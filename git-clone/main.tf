terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.12"
    }
  }
}

variable "url" {
  description = "The URL of the Git repository."
  type        = string
}

variable "path" {
  default     = ""
  description = "The path to clone the repository. Defaults to \"$HOME/<basename of url>\"."
  type        = string
}

variable "agent_id" {
  description = "The ID of a Coder agent."
  type        = string
}

locals {
  clone_path = var.path != "" ? join("/", [var.path, replace(basename(var.url), ".git", "")]) : join("/", ["~", replace(basename(var.url), ".git", "")])
}

output "repo_dir" {
  value       = local.clone_path
  description = "Full path of cloned repo directory"
}

resource "coder_script" "git_clone" {
  agent_id = var.agent_id
  script = templatefile("${path.module}/run.sh", {
    CLONE_PATH = local.clone_path
    REPO_URL : var.url,
  })
  display_name       = "Git Clone"
  icon               = "/icon/git.svg"
  run_on_start       = true
  start_blocks_login = true
}
