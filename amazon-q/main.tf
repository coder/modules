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
  default     = "/icon/amazon-q.svg"
}

variable "folder" {
  type        = string
  description = "The folder to run Amazon Q in."
  default     = "/home/coder"
}

variable "install_amazon_q" {
  type        = bool
  description = "Whether to install Amazon Q."
  default     = true
}

variable "amazon_q_version" {
  type        = string
  description = "The version of Amazon Q to install."
  default     = "latest"
}

variable "experiment_use_screen" {
  type        = bool
  description = "Whether to use screen for running Amazon Q in the background."
  default     = false
}

variable "experiment_use_tmux" {
  type        = bool
  description = "Whether to use tmux instead of screen for running Amazon Q in the background."
  default     = false
}

variable "experiment_report_tasks" {
  type        = bool
  description = "Whether to enable task reporting."
  default     = false
}

variable "experiment_pre_install_script" {
  type        = string
  description = "Custom script to run before installing Amazon Q."
  default     = null
}

variable "experiment_post_install_script" {
  type        = string
  description = "Custom script to run after installing Amazon Q."
  default     = null
}

variable "experiment_auth_tarball" {
  type        = string
  description = "Base64 encoded, zstd compressed tarball of a pre-authenticated ~/.local/share/amazon-q directory. After running `q login` on another machine, you may generate it with: `cd ~/.local/share/amazon-q && tar -c . | zstd | base64 -w 0`"
  default     = null
}

locals {
  encoded_pre_install_script  = var.experiment_pre_install_script != null ? base64encode(var.experiment_pre_install_script) : ""
  encoded_post_install_script = var.experiment_post_install_script != null ? base64encode(var.experiment_post_install_script) : ""
  # We need to use allowed tools to limit the context Amazon Q receives.
  # Amazon Q can't handle big contexts, and the `create_template_version` tool
  # has a description that's too long.
  mcp_json         = <<EOT
    {
      "mcpServers": {
        "coder": {
          "command": "coder",
          "args": ["exp", "mcp", "server", "--allowed-tools", "coder_report_task"],
          "env": {
            "CODER_MCP_APP_STATUS_SLUG": "amazon-q"
          }
        }
      }
    }
  EOT
  encoded_mcp_json = base64encode(local.mcp_json)
}



# Install and Initialize Amazon Q
resource "coder_script" "amazon_q" {
  agent_id     = var.agent_id
  display_name = "Amazon Q"
  icon         = var.icon
  script       = <<-EOT
    #!/bin/bash
    set -o errexit
    set -o pipefail

    # Function to check if a command exists
    command_exists() {
      command -v "$1" >/dev/null 2>&1
    }

    # Run pre-install script if provided
    if [ -n "${local.encoded_pre_install_script}" ]; then
      echo "Running pre-install script..."
      echo "${local.encoded_pre_install_script}" | base64 -d > /tmp/pre_install.sh
      chmod +x /tmp/pre_install.sh
      /tmp/pre_install.sh
    fi

    # Install Amazon Q if enabled
    if [ "${var.install_amazon_q}" = "true" ]; then
      echo "Installing Amazon Q..."
      PREV_DIR="$PWD"
      TMP_DIR="$(mktemp -d)"
      cd "$TMP_DIR"
      curl --proto '=https' --tlsv1.2 -sSf "https://desktop-release.q.us-east-1.amazonaws.com/${var.amazon_q_version}/q-x86_64-linux.zip" -o "q.zip"
      unzip q.zip
      ./q/install.sh --no-confirm
      cd "$PREV_DIR"
      export PATH="$PATH:$HOME/.local/bin"
      echo "Installed Amazon Q version: $(q --version)"
    fi

    echo "Extracting auth tarball..."
    PREV_DIR="$PWD"
    echo "${var.experiment_auth_tarball}" | base64 -d > /tmp/auth.tar.zst
    rm -rf ~/.local/share/amazon-q
    mkdir -p ~/.local/share/amazon-q
    cd ~/.local/share/amazon-q
    tar -I zstd -xf /tmp/auth.tar.zst
    rm /tmp/auth.tar.zst
    cd "$PREV_DIR"
    echo "Extracted auth tarball"

    # Run post-install script if provided
    if [ -n "${local.encoded_post_install_script}" ]; then
      echo "Running post-install script..."
      echo "${local.encoded_post_install_script}" | base64 -d > /tmp/post_install.sh
      chmod +x /tmp/post_install.sh
      /tmp/post_install.sh
    fi

    if [ "${var.experiment_report_tasks}" = "true" ]; then
      echo "Configuring Amazon Q to report tasks via Coder MCP..."      
      mkdir -p ~/.aws/amazonq
      echo "${local.encoded_mcp_json}" | base64 -d > ~/.aws/amazonq/mcp.json
      echo "Created the ~/.aws/amazonq/mcp.json configuration file"
    fi

    # Handle terminal multiplexer selection (tmux or screen)
    if [ "${var.experiment_use_tmux}" = "true" ] && [ "${var.experiment_use_screen}" = "true" ]; then
      echo "Error: Both experiment_use_tmux and experiment_use_screen cannot be true simultaneously."
      echo "Please set only one of them to true."
      exit 1
    fi

    FULL_PROMPT="$(printf "%s\n\nYour first task is:\n\n%s" "$CODER_MCP_AMAZON_Q_SYSTEM_PROMPT" "$CODER_MCP_AMAZON_Q_TASK_PROMPT")"

    # Run with tmux if enabled
    if [ "${var.experiment_use_tmux}" = "true" ]; then
      echo "Running Amazon Q in the background with tmux..."
      
      # Check if tmux is installed
      if ! command_exists tmux; then
        echo "Error: tmux is not installed. Please install tmux manually."
        exit 1
      fi

      touch "$HOME/.amazon-q.log"
      
      export LANG=en_US.UTF-8
      export LC_ALL=en_US.UTF-8
      
      # Create a new tmux session in detached mode
      tmux new-session -d -s amazon-q -c "${var.folder}" "q chat --trust-all-tools | tee -a "$HOME/.amazon-q.log" && exec bash"
      
      # Send the prompt to the tmux session if needed
      if [ -n "$FULL_PROMPT" ]; then
        tmux send-keys -t amazon-q "$FULL_PROMPT"
        sleep 5
        tmux send-keys -t amazon-q Enter
      fi
    fi

    # Run with screen if enabled
    if [ "${var.experiment_use_screen}" = "true" ]; then
      echo "Running Amazon Q in the background..."
      
      # Check if screen is installed
      if ! command_exists screen; then
        echo "Error: screen is not installed. Please install screen manually."
        exit 1
      fi

      touch "$HOME/.amazon-q.log"

      # Ensure the screenrc exists
      if [ ! -f "$HOME/.screenrc" ]; then
        echo "Creating ~/.screenrc and adding multiuser settings..." | tee -a "$HOME/.amazon-q.log"
        echo -e "multiuser on\nacladd $(whoami)" > "$HOME/.screenrc"
      fi
      
      if ! grep -q "^multiuser on$" "$HOME/.screenrc"; then
        echo "Adding 'multiuser on' to ~/.screenrc..." | tee -a "$HOME/.amazon-q.log"
        echo "multiuser on" >> "$HOME/.screenrc"
      fi

      if ! grep -q "^acladd $(whoami)$" "$HOME/.screenrc"; then
        echo "Adding 'acladd $(whoami)' to ~/.screenrc..." | tee -a "$HOME/.amazon-q.log"
        echo "acladd $(whoami)" >> "$HOME/.screenrc"
      fi
      export LANG=en_US.UTF-8
      export LC_ALL=en_US.UTF-8
      
      screen -U -dmS amazon-q bash -c '
        cd ${var.folder}
        q chat --trust-all-tools | tee -a "$HOME/.amazon-q.log
        exec bash
      '
      # Extremely hacky way to send the prompt to the screen session
      # This will be fixed in the future, but `amazon-q` was not sending MCP
      # tasks when an initial prompt is provided.
      screen -S amazon-q -X stuff "$FULL_PROMPT"
      sleep 5
      screen -S amazon-q -X stuff "^M"
    else
      # Check if amazon-q is installed before running
      if ! command_exists q; then
        echo "Error: Amazon Q is not installed. Please enable install_amazon_q or install it manually."
        exit 1
      fi
    fi
    EOT
  run_on_start = true
}

resource "coder_app" "amazon_q" {
  slug         = "amazon-q"
  display_name = "Amazon Q"
  agent_id     = var.agent_id
  command      = <<-EOT
    #!/bin/bash
    set -e

    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8

    if [ "${var.experiment_use_tmux}" = "true" ]; then
      if tmux has-session -t amazon-q 2>/dev/null; then
        echo "Attaching to existing Amazon Q tmux session." | tee -a "$HOME/.amazon-q.log"
        tmux attach-session -t amazon-q
      else
        echo "Starting a new Amazon Q tmux session." | tee -a "$HOME/.amazon-q.log"
        tmux new-session -s amazon-q -c ${var.folder} "q chat --trust-all-tools | tee -a \"$HOME/.amazon-q.log\"; exec bash"
      fi
    elif [ "${var.experiment_use_screen}" = "true" ]; then
      if screen -list | grep -q "amazon-q"; then
        echo "Attaching to existing Amazon Q screen session." | tee -a "$HOME/.amazon-q.log"
        screen -xRR amazon-q
      else
        echo "Starting a new Amazon Q screen session." | tee -a "$HOME/.amazon-q.log"
        screen -S amazon-q bash -c 'q chat --trust-all-tools | tee -a "$HOME/.amazon-q.log"; exec bash'
      fi
    else
      cd ${var.folder}
      q chat --trust-all-tools
    fi
    EOT
  icon         = var.icon
}
