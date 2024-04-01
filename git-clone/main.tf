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

variable "base_dir" {
  default     = ""
  description = "The base directory to clone the repository. Defaults to \"$HOME\"."
  type        = string
}

variable "agent_id" {
  description = "The ID of a Coder agent."
  type        = string
}

locals {
  clone_url   = replace(replace(var.url, "//-/tree/.*/", ""), "//tree/.*/", "")
  branch_name = replace(replace(replace(var.url, local.clone_url, ""), "/.*/-/tree//", ""), "/.*/tree//", "")
  clone_path  = var.base_dir != "" ? join("/", [var.base_dir, replace(basename(local.clone_url), ".git", "")]) : join("/", ["~", replace(basename(local.clone_url), ".git", "")])
}

output "repo_dir" {
  value       = local.clone_path
  description = "Full path of cloned repo directory"
}

output "clone_url" {
  value       = local.clone_url
  description = "Git repository URL"
}

output "branch_name" {
  value       = local.branch_name
  description = "Git branch"
}

resource "coder_script" "git_clone" {
  agent_id = var.agent_id
  script = templatefile("${path.module}/run.sh", {
    CLONE_PATH = local.clone_path,
    REPO_URL : local.clone_url,
    BRANCH_NAME : local.branch_name,
  })
  display_name       = "Git Clone"
  icon               = "/icon/git.svg"
  run_on_start       = true
  start_blocks_login = true
}
