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
  default     = "/icon/goose.svg"
}

variable "folder" {
  type        = string
  description = "The folder to run Goose in."
  default     = "/home/coder"
}

variable "install_goose" {
  type        = bool
  description = "Whether to install Goose."
  default     = true
}

variable "goose_version" {
  type        = string
  description = "The version of Goose to install."
  default     = "stable"
}

variable "experiment_use_screen" {
  type        = bool
  description = "Whether to use screen for running Goose in the background."
  default     = false
}

variable "experiment_report_tasks" {
  type        = bool
  description = "Whether to enable task reporting."
  default     = false
}

variable "experiment_auto_configure" {
  type        = bool
  description = "Whether to automatically configure Goose."
  default     = false
}

variable "experiment_goose_provider" {
  type        = string
  description = "The provider to use for Goose (e.g., anthropic)."
  default     = null
}

variable "experiment_goose_model" {
  type        = string
  description = "The model to use for Goose (e.g., claude-3-5-sonnet-latest)."
  default     = null
}

variable "experiment_pre_install_script" {
  type        = string
  description = "Custom script to run before installing Goose."
  default     = null
}

variable "experiment_post_install_script" {
  type        = string
  description = "Custom script to run after installing Goose."
  default     = null
}

# Install and Initialize Goose
resource "coder_script" "goose" {
  agent_id     = var.agent_id
  display_name = "Goose"
  icon         = var.icon
  script       = <<-EOT
    #!/bin/bash
    set -e

    # Function to check if a command exists
    command_exists() {
      command -v "$1" >/dev/null 2>&1
    }

    # Run pre-install script if provided
    PRE_INSTALL_SCRIPT="${var.experiment_pre_install_script != null ? var.experiment_pre_install_script : ""}"
    if [ -n "$PRE_INSTALL_SCRIPT" ]; then
      echo "Running pre-install script..."
      eval "$PRE_INSTALL_SCRIPT"
    fi

    # Store current PATH for screen session
    export PATH_FOR_SCREEN="$PATH"

    # Install Goose if enabled
    if [ "${var.install_goose}" = "true" ]; then
      if ! command_exists npm; then
        echo "Error: npm is not installed. Please install Node.js and npm first."
        exit 1
      fi
      echo "Installing Goose..."
      RELEASE_TAG=v${var.goose_version} curl -fsSL https://github.com/block/goose/releases/download/stable/download_cli.sh | CONFIGURE=false bash
    fi

    # Run post-install script if provided
    POST_INSTALL_SCRIPT="${var.experiment_post_install_script != null ? var.experiment_post_install_script : ""}"
    if [ -n "$POST_INSTALL_SCRIPT" ]; then
      echo "Running post-install script..."
      eval "$POST_INSTALL_SCRIPT"
    fi

    # Configure Goose if auto-configure is enabled
    if [ "${var.experiment_auto_configure}" = "true" ]; then
      echo "Configuring Goose..."
      mkdir -p "$HOME/.config/goose"
      cat > "$HOME/.config/goose/config.yaml" << EOL
GOOSE_PROVIDER: ${var.experiment_goose_provider}
GOOSE_MODEL: ${var.experiment_goose_model}
extensions:
  coder:
    args:
    - exp
    - mcp
    - server
    cmd: coder
    description: Report ALL tasks and statuses (in progress, done, failed) before and after starting
    enabled: true
    envs:
      CODER_MCP_APP_STATUS_SLUG: goose
    name: Coder
    timeout: 3000
    type: stdio
  developer:
    display_name: Developer
    enabled: true
    name: developer
    timeout: 300
    type: builtin
EOL
    fi
    
    # Run with screen if enabled
    if [ "${var.experiment_use_screen}" = "true" ]; then
      echo "Running Goose in the background..."
      
      # Check if screen is installed
      if ! command_exists screen; then
        echo "Error: screen is not installed. Please install screen manually."
        exit 1
      fi

      touch "$HOME/.goose.log"

      # Ensure the screenrc exists
      if [ ! -f "$HOME/.screenrc" ]; then
        echo "Creating ~/.screenrc and adding multiuser settings..." | tee -a "$HOME/.goose.log"
        echo -e "multiuser on\nacladd $(whoami)" > "$HOME/.screenrc"
      fi
      
      if ! grep -q "^multiuser on$" "$HOME/.screenrc"; then
        echo "Adding 'multiuser on' to ~/.screenrc..." | tee -a "$HOME/.goose.log"
        echo "multiuser on" >> "$HOME/.screenrc"
      fi

      if ! grep -q "^acladd $(whoami)$" "$HOME/.screenrc"; then
        echo "Adding 'acladd $(whoami)' to ~/.screenrc..." | tee -a "$HOME/.goose.log"
        echo "acladd $(whoami)" >> "$HOME/.screenrc"
      fi
      export LANG=en_US.UTF-8
      export LC_ALL=en_US.UTF-8
      
      # Determine goose command
      if command_exists goose; then
        GOOSE_CMD=goose
      elif [ -f "$HOME/.local/bin/goose" ]; then
        GOOSE_CMD="$HOME/.local/bin/goose"
      else
        echo "Error: Goose is not installed. Please enable install_goose or install it manually."
        exit 1
      fi
      
      screen -U -dmS goose bash -c "
        cd ${var.folder}
        export PATH=\"$PATH\"
        echo \"Starting goose with command: $GOOSE_CMD\" | tee -a \"$HOME/.goose.log\"
        echo \"Current PATH: $PATH\" | tee -a \"$HOME/.goose.log\"
        echo \"Current directory: $(pwd)\" | tee -a \"$HOME/.goose.log\"
        echo \"Goose version: $(\"$GOOSE_CMD\" --version 2>&1)\" | tee -a \"$HOME/.goose.log\"
        echo \"Running goose command...\" | tee -a \"$HOME/.goose.log\"
        \"$GOOSE_CMD\" run --text \"$GOOSE_SYSTEM_PROMPT. Your task: $GOOSE_TASK_PROMPT\" --interactive 2>&1 | tee -a \"$HOME/.goose.log\"
        EXIT_CODE=\$?
        echo \"Goose exited with code: \$EXIT_CODE\" | tee -a \"$HOME/.goose.log\"
        exec bash
      "
    else
      # Check if goose is installed before running
      if command_exists goose; then
        GOOSE_CMD=goose
      elif [ -f "$HOME/.local/bin/goose" ]; then
        GOOSE_CMD="$HOME/.local/bin/goose"
      else
        echo "Error: Goose is not installed. Please enable install_goose or install it manually."
        exit 1
      fi
    fi
    EOT
  run_on_start = true
}

resource "coder_app" "goose" {
  slug         = "goose"
  display_name = "Goose"
  agent_id     = var.agent_id
  command      = <<-EOT
    #!/bin/bash
    set -e

    # Function to check if a command exists
    command_exists() {
      command -v "$1" >/dev/null 2>&1
    }

    # Determine goose command
    if command_exists goose; then
      GOOSE_CMD=goose
    elif [ -f "$HOME/.local/bin/goose" ]; then
      GOOSE_CMD="$HOME/.local/bin/goose"
    else
      echo "Error: Goose is not installed. Please enable install_goose or install it manually."
      exit 1
    fi

    if [ "${var.experiment_use_screen}" = "true" ]; then
      echo "Checking for existing screen sessions..." | tee -a "$HOME/.goose.log"
      screen -list | tee -a "$HOME/.goose.log"
      
      # Check if the session exists and is attached
      if screen -list | grep -q "goose.*(Attached)"; then
        echo "Found attached Goose session, reattaching..." | tee -a "$HOME/.goose.log"
        screen -x goose
      elif screen -list | grep -q "goose.*(Detached)"; then
        echo "Found detached Goose session, attaching..." | tee -a "$HOME/.goose.log"
        screen -r goose
      else
        echo "No existing Goose session found, starting new one..." | tee -a "$HOME/.goose.log"
        screen -S goose bash -c "export PATH=\"$PATH\"; export LANG=en_US.UTF-8; export LC_ALL=en_US.UTF-8; echo \"Starting goose with command: $GOOSE_CMD\" | tee -a \"$HOME/.goose.log\"; echo \"Current PATH: $PATH\" | tee -a \"$HOME/.goose.log\"; echo \"Current directory: $(pwd)\" | tee -a \"$HOME/.goose.log\"; echo \"Goose version: $(\"$GOOSE_CMD\" --version 2>&1)\" | tee -a \"$HOME/.goose.log\"; echo \"Running goose command...\" | tee -a \"$HOME/.goose.log\"; \"$GOOSE_CMD\" run --text \"Always report status and instructions to Coder, before and after your steps\" --interactive 2>&1 | tee -a \"$HOME/.goose.log\"; EXIT_CODE=\$?; echo \"Goose exited with code: \$EXIT_CODE\" | tee -a \"$HOME/.goose.log\"; exec bash"
      fi
    else
      cd ${var.folder}
      export LANG=en_US.UTF-8
      export LC_ALL=en_US.UTF-8
      "$GOOSE_CMD" run --text "Always report status and instructions to Coder, before and after your steps" --interactive
    fi
    EOT
  icon         = var.icon
}
