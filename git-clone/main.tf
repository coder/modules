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
  # Remove query parameters and branch name from the URL
  url = replace(replace(var.url, "/\\?.*/", ""), "/#.*", "")
  # Remove tree and branch name from the URL
  clone_url = replace(replace(local.url, "//-/tree/.*/", ""), "//tree/.*/", "")
  # Extract the branch name from the URL
  branch_name = replace(replace(replace(local.url, local.clone_url, ""), "/.*/-/tree//", ""), "/.*/tree//", "")
  # Construct the path to clone the repository
  clone_path = var.base_dir != "" ? join("/", [var.base_dir, replace(basename(local.clone_url), ".git", "")]) : join("/", ["~", replace(basename(local.clone_url), ".git", "")])

  # git@gitlab.com:mike.brew/repo-tests.log.git
  # becomes https://gitlab.com/mike.brew/repo-tests.log.git
  web_url = startswith(local.clone_url, "git@") ? replace(replace(local.clone_url, ":", "/"), "git@", "https://") : local.clone_url
}

output "repo_dir" {
  value       = local.clone_path
  description = "Full path of cloned repo directory"
}

output "clone_url" {
  value       = local.clone_url
  description = "Git repository URL"
}

output "web_url" {
  value       = local.web_url
  description = "Git https repository URL"
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
