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
  default     = false
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

variable "experiment_report_tasks" {
  type        = bool
  description = "Whether to enable task reporting."
  default     = false
}

variable "experiment_pre_install_script" {
  type        = string
  description = "Custom script to run before installing Aider."
  default     = null
}

variable "experiment_post_install_script" {
  type        = string
  description = "Custom script to run after installing Aider."
  default     = null
}


locals {
  encoded_pre_install_script  = var.experiment_pre_install_script != null ? base64encode(var.experiment_pre_install_script) : ""
  encoded_post_install_script = var.experiment_post_install_script != null ? base64encode(var.experiment_post_install_script) : ""
}

# Install and Initialize Aider
resource "coder_script" "aider" {
  agent_id     = var.agent_id
  display_name = "Aider"
  icon         = "/icon/terminal.svg"
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

    # Run pre-install script if provided
    if [ -n "${local.encoded_pre_install_script}" ]; then
      echo "Running pre-install script..."
      echo "${local.encoded_pre_install_script}" | base64 -d > /tmp/pre_install.sh
      chmod +x /tmp/pre_install.sh
      /tmp/pre_install.sh
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
    
    # Run post-install script if provided
    if [ -n "${local.encoded_post_install_script}" ]; then
      echo "Running post-install script..."
      echo "${local.encoded_post_install_script}" | base64 -d > /tmp/post_install.sh
      chmod +x /tmp/post_install.sh
      /tmp/post_install.sh
    fi
    
    # Configure task reporting if enabled
    if [ "${var.experiment_report_tasks}" = "true" ]; then
      echo "Configuring Aider to report tasks via Coder MCP..."
      coder exp mcp configure aider ${var.folder}
    fi

    # Start a persistent session at workspace creation
    echo "Starting persistent Aider session..."
    
    # Create a log file to store session output
    touch "$HOME/.aider.log"
    
    # Set up environment for UTF-8 support
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    
    if [ "${var.use_tmux}" = "true" ]; then
      # Create a new detached tmux session
      tmux new-session -d -s ${var.session_name} -c ${var.folder} "aider"
      
      # Send the prompt to the tmux session if needed
      if [ -n "$CODER_MCP_CLAUDE_TASK_PROMPT" ]; then
        echo "Sending initial prompt to Aider tmux session..."
        sleep 5 # Wait for Aider to initialize
        tmux send-keys -t ${var.session_name} "$CODER_MCP_CLAUDE_TASK_PROMPT"
        sleep 2
        tmux send-keys -t ${var.session_name} Enter
      fi
      
      echo "Tmux session '${var.session_name}' started. Access it by clicking the Aider button."
    else
      # Create a new detached screen session
      screen -dmS ${var.session_name} bash -c "cd ${var.folder} && aider | tee -a \"$HOME/.aider.log\"; exec bash"
      
      # Send the prompt to the screen session if needed
      if [ -n "$CODER_MCP_CLAUDE_TASK_PROMPT" ]; then
        echo "Sending initial prompt to Aider screen session..."
        sleep 5 # Wait for Aider to initialize
        screen -S ${var.session_name} -X stuff "$CODER_MCP_CLAUDE_TASK_PROMPT"
        sleep 2
        screen -S ${var.session_name} -X stuff "^M"
      fi
      
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
  icon         = var.icon
  command      = <<-EOT
    #!/bin/bash
    set -e
    
    # Ensure binaries are in path
    export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
    
    # Environment variables are set in the agent template
    
    # Set up environment for UTF-8 support
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    
    # Check if we should use tmux
    if [ "${var.use_tmux}" = "true" ]; then
      # Check if session exists, attach or create
      if tmux has-session -t ${var.session_name} 2>/dev/null; then
        echo "Attaching to existing Aider tmux session..." | tee -a "$HOME/.aider.log"
        tmux attach-session -t ${var.session_name}
      else
        echo "Starting new Aider tmux session..." | tee -a "$HOME/.aider.log"
        tmux new-session -s ${var.session_name} -c ${var.folder} "aider | tee -a \"$HOME/.aider.log\"; exec bash"
      fi
    elif [ "${var.use_screen}" = "true" ]; then
      # Use screen
      # Check if session exists, attach or create
      if screen -list | grep -q "\\.${var.session_name}\|${var.session_name}\\"; then
        echo "Attaching to existing Aider screen session..." | tee -a "$HOME/.aider.log"
        # Get the full screen session name (with PID) and attach to it
        SCREEN_NAME=$(screen -list | grep -o "[0-9]*\\.${var.session_name}" || screen -list | grep -o "${var.session_name}[0-9]*")
        screen -r "$SCREEN_NAME"
      else
        echo "Starting new Aider screen session..." | tee -a "$HOME/.aider.log" 
        screen -S ${var.session_name} bash -c "cd ${var.folder} && aider | tee -a \"$HOME/.aider.log\"; exec bash"
      fi
    else
      # Run directly without a multiplexer
      cd "${var.folder}"
      echo "Starting Aider directly..." | tee -a "$HOME/.aider.log"
      aider
    fi
  EOT
  order        = var.order
}
