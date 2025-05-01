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
  default     = "/icon/terminal.svg"
}

variable "folder" {
  type        = string
  description = "The folder to run Aider in."
  default     = "/home/coder"
}

variable "install_aider" {
  type        = bool
  description = "Whether to install Aider."
  default     = true
}

variable "aider_version" {
  type        = string
  description = "The version of Aider to install."
  default     = "latest"
}

variable "use_screen" {
  type        = bool
  description = "Whether to use screen for running Aider in the background"
  default     = true
}

variable "use_tmux" {
  type        = bool
  description = "Whether to use tmux instead of screen for running Aider in the background"
  default     = false
}

variable "session_name" {
  type        = string
  description = "Name for the persistent session (screen or tmux)"
  default     = "aider"
}



locals {
  # Default icon for Aider
  icon = "/icon/terminal.svg"
  
  # Basic aider command
  aider_command = "aider"
}

# Install and Initialize Aider
resource "coder_script" "aider" {
  agent_id     = var.agent_id
  display_name = "Aider"
  icon         = local.icon
  script       = <<-EOT
    #!/bin/bash
    set -e

    # Function to check if a command exists
    command_exists() {
      command -v "$1" >/dev/null 2>&1
    }

    echo "Setting up Aider AI pair programming..."
    
    # Create the workspace folder
    mkdir -p "${var.folder}"

    # Install essential dependencies
    if [ "$(uname)" = "Linux" ]; then
      echo "Installing dependencies on Linux..."
      if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update -qq
        
        # Install terminal multiplexers for persistent sessions
        if [ "${var.use_tmux}" = "true" ]; then
          echo "Installing tmux for persistent sessions..."
          sudo apt-get install -y -qq python3-pip python3-venv tmux
        else
          echo "Installing screen for persistent sessions..."
          sudo apt-get install -y -qq python3-pip python3-venv screen
        fi
      elif command -v dnf >/dev/null 2>&1; then
        # For Red Hat-based distros
        if [ "${var.use_tmux}" = "true" ]; then
          echo "Installing tmux for persistent sessions..."
          sudo dnf install -y -q python3-pip python3-virtualenv tmux
        else
          echo "Installing screen for persistent sessions..."
          sudo dnf install -y -q python3-pip python3-virtualenv screen
        fi
      fi
    elif [ "$(uname)" = "Darwin" ]; then
      echo "Installing dependencies on macOS..."
      if ! command_exists brew; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
      if [ "${var.use_tmux}" = "true" ]; then
        brew install -q python3 tmux
      else
        brew install -q python3 screen
      fi
    fi

    # Install Aider using the official installation script
    if [ "${var.install_aider}" = "true" ]; then
      echo "Installing Aider..."
      
      # Use official installation script
      if ! command -v aider &> /dev/null; then
        curl -LsSf https://aider.chat/install.sh | sh
      fi
      
      # Add required paths to shell configuration
      if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$HOME/.bashrc"; then
          echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
        fi
      fi
      
      if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$HOME/.zshrc"; then
          echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.zshrc"
        fi
      fi
      
      # Aider configuration is handled through environment variables
      # or external dotenv module
    fi

    # Start a persistent session at workspace creation
    echo "Starting persistent Aider session..."
    if [ "${var.use_tmux}" = "true" ]; then
      # Create a new detached tmux session
      tmux new-session -d -s ${var.session_name} "cd ${var.folder} && ${local.aider_command}; exec bash"
      echo "Tmux session '${var.session_name}' started. Access it by clicking the Aider button."
    else
      # Create a new detached screen session
      screen -dmS ${var.session_name} bash -c "cd ${var.folder} && ${local.aider_command}; exec bash"
      echo "Screen session '${var.session_name}' started. Access it by clicking the Aider button."
    fi
    
    echo "Aider setup complete!"
  EOT
  run_on_start = true
}

# Aider CLI app
resource "coder_app" "aider_cli" {
  agent_id     = var.agent_id
  slug         = "aider"
  display_name = "Aider"
  icon         = local.icon
  command      = <<-EOT
    #!/bin/bash
    set -e
    
    # Ensure binaries are in path
    export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
    
    # Environment variables are set in the agent template
    
    cd "${var.folder}"
    
    # Check if we should use tmux
    if [ "${var.use_tmux}" = "true" ]; then
      # Check if session exists, attach or create
      if tmux has-session -t ${var.session_name} 2>/dev/null; then
        echo "Attaching to existing Aider tmux session..."
        tmux attach-session -t ${var.session_name}
      else
        echo "Starting new Aider tmux session..."
        tmux new-session -s ${var.session_name} "${local.aider_command}; exec bash"
      fi
    else
      # Default to screen
      # Check if session exists, attach or create
      if screen -list | grep -q "\\.${var.session_name}\|${var.session_name}\\"; then
        echo "Attaching to existing Aider screen session..."
        # Get the full screen session name (with PID) and attach to it
        SCREEN_NAME=$(screen -list | grep -o "[0-9]*\\.${var.session_name}" || screen -list | grep -o "${var.session_name}[0-9]*")
        screen -r "$SCREEN_NAME"
      else
        echo "Starting new Aider screen session..."
        screen -S ${var.session_name} bash -c "${local.aider_command}; exec bash"
      fi
    fi
  EOT
  order        = var.order
}
