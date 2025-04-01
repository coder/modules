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

data "coder_workspace" "me" {}

data "coder_workspace_owner" "me" {}

variable "order" {
  type        = number
  description = "The order determines the position of app in the UI presentation. The lowest order is shown first and apps with equal order are sorted by name (ascending order)."
  default     = null
}

variable "icon" {
  type        = string
  description = "The icon to use for the app."
  default     = "/icon/claude.svg"
}

variable "folder" {
  type        = string
  description = "The folder to run Claude Code in."
  default     = "/home/coder"
}

variable "install_claude_code" {
  type        = bool
  description = "Whether to install Claude Code."
  default     = true
}

variable "claude_code_version" {
  type        = string
  description = "The version of Claude Code to install."
  default     = "latest"
}

variable "experiment_use_screen" {
  type        = bool
  description = "Whether to use screen for running Claude Code in the background."
  default     = false
}

variable "experiment_report_tasks" {
  type        = bool
  description = "Whether to enable task reporting."
  default     = false
}

variable "experiment_init_script" {
  type        = string
  description = "Additional initialization script to run before starting Claude Code."
  default     = ""
}

# Install and Initialize Claude Code
resource "coder_script" "claude_code" {
  agent_id     = var.agent_id
  display_name = "Claude Code"
  icon         = var.icon
  script       = <<-EOT
    #!/bin/bash
    set -e

    # Function to check if a command exists
    command_exists() {
      command -v "$1" >/dev/null 2>&1
    }

    # Run init script if provided
    if [ -n "${var.experiment_init_script}" ]; then
      echo "Running init script..."
      ${var.experiment_init_script}
    fi

    # Install Claude Code if enabled
    if [ "${var.install_claude_code}" = "true" ]; then
      if ! command_exists npm; then
        echo "Error: npm is not installed. Please install Node.js and npm first."
        exit 1
      fi
      echo "Installing Claude Code version ${var.claude_code_version}..."
      npm install -g @anthropic-ai/claude-code@${var.claude_code_version}
    fi

    # Run with screen if enabled
    if [ "${var.experiment_use_screen}" = "true" ]; then
      echo "Running Claude Code in the background..."
      
      # Check if screen is installed
      if ! command_exists screen; then
        echo "Error: screen is not installed. Please install screen manually."
        exit 1
      fi

      SCREENRC="$HOME/.screenrc"
      LOG_FILE="$HOME/.claude-code.log"
      touch "$LOG_FILE"

      # Ensure the screenrc exists
      if [ ! -f "$SCREENRC" ]; then
        echo "Creating ~/.screenrc and adding multiuser settings..." | tee -a "$LOG_FILE"
        echo -e "multiuser on\nacladd $(whoami)" > "$SCREENRC"
      fi
      
      if ! grep -q "^multiuser on$" "$SCREENRC"; then
        echo "Adding 'multiuser on' to ~/.screenrc..." | tee -a "$LOG_FILE"
        echo "multiuser on" >> "$SCREENRC"
      fi

      if ! grep -q "^acladd $(whoami)$" "$SCREENRC"; then
        echo "Adding 'acladd $(whoami)' to ~/.screenrc..." | tee -a "$LOG_FILE"
        echo "acladd $(whoami)" >> "$SCREENRC"
      fi
      
      screen -U -dmS claude-code bash -c '
        export LANG=en_US.UTF-8
        export LC_ALL=en_US.UTF-8
        cd ${var.folder}
        claude | tee -a "$LOG_FILE"
        exec bash
      '
    else
      # Check if claude is installed before running
      if ! command_exists claude; then
        echo "Error: Claude Code is not installed. Please enable install_claude_code or install it manually."
        exit 1
      fi
      
      cd ${var.folder}
      export LANG=en_US.UTF-8
      export LC_ALL=en_US.UTF-8
      claude
    fi
    EOT
  run_on_start = true
}

resource "coder_app" "claude_code" {
  slug         = "claude-code"
  display_name = "Claude Code"
  agent_id     = var.agent_id
  command      = <<-EOT
    #!/bin/bash
    set -e

    # Function to check if a command exists
    command_exists() {
      command -v "$1" >/dev/null 2>&1
    }

    # Check if claude is installed
    if ! command_exists claude; then
      echo "Error: Claude Code is not installed. Please enable install_claude_code or install it manually."
      exit 1
    fi

    if [ "${var.experiment_use_screen}" = "true" ]; then
      # Check if screen is installed
      if ! command_exists screen; then
        echo "Error: screen is not installed. Please install screen manually."
        exit 1
      fi

      if screen -list | grep -q "claude-code"; then
        echo "Attaching to existing Claude Code session." | tee -a "$LOG_FILE"
        screen -xRR claude-code
      else
        echo "Starting a new Claude Code session." | tee -a "$LOG_FILE"
        screen -S claude-code bash -c 'export LANG=en_US.UTF-8; export LC_ALL=en_US.UTF-8; claude | tee -a "$LOG_FILE"; exec bash'
      fi
    else
      cd ${var.folder}
      export LANG=en_US.UTF-8
      export LC_ALL=en_US.UTF-8
      claude
    fi
    EOT
  icon         = var.icon
}
