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
  default     = "/icon/aider.svg"
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

variable "experiment_report_tasks" {
  type        = bool
  description = "Whether to enable task reporting."
  default     = true
}

variable "experiment_task_conventions" {
  type        = string
  description = "Custom conventions for task reporting to be written to CONVENTIONS.md"
  default     = <<-EOT
# Aider Coding Conventions

## Task Reporting Requirements

As you work on tasks, you MUST follow these task reporting conventions:

1. ALWAYS report the status of each task to Coder before and after your steps.
2. Use the following format for reporting tasks:
   ```
   TASK: [brief description of what you're doing]
   STATUS: [one of: "started", "in progress", "done", "failed"]
   ```

3. Send a task report in these specific situations:
   - When you BEGIN working on a task
   - When you make SIGNIFICANT PROGRESS on a task
   - When you COMPLETE a task successfully
   - When you ENCOUNTER AN ERROR or cannot complete a task

4. Example sequence of task reporting:
   ```
   TASK: Setting up project structure
   STATUS: started
   
   [Your work and discussion here]
   
   TASK: Setting up project structure
   STATUS: in progress
   
   [More work and discussion]
   
   TASK: Setting up project structure
   STATUS: done
   
   TASK: Implementing feature X
   STATUS: started
   ```

5. Always include a brief but descriptive task name that clearly identifies what you're working on.

These conventions ensure that Coder can properly track task status in the UI.
EOT
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

variable "experiment_additional_extensions" {
  type        = string
  description = "Additional extensions configuration in YAML format to append to the config."
  default     = null
}

locals {
  base_extensions = <<-EOT
coder:
  args:
  - exp
  - mcp
  - server
  cmd: coder
  description: Report ALL tasks and statuses (in progress, done, failed) you are working on.
  enabled: true
  envs:
    CODER_MCP_APP_STATUS_SLUG: aider
  name: Coder
  timeout: 3000
  type: stdio
developer:
  display_name: Developer
  enabled: true
  name: developer
  timeout: 300
  type: builtin
EOT

  # Add two spaces to each line of extensions to match YAML structure
  formatted_base        = "  ${replace(trimspace(local.base_extensions), "\n", "\n  ")}"
  additional_extensions = var.experiment_additional_extensions != null ? "\n  ${replace(trimspace(var.experiment_additional_extensions), "\n", "\n  ")}" : ""

  combined_extensions = <<-EOT
extensions:
${local.formatted_base}${local.additional_extensions}
EOT

  encoded_pre_install_script  = var.experiment_pre_install_script != null ? base64encode(var.experiment_pre_install_script) : ""
  encoded_post_install_script = var.experiment_post_install_script != null ? base64encode(var.experiment_post_install_script) : ""
}

# Install and Initialize Aider
resource "coder_script" "aider" {
  agent_id     = var.agent_id
  display_name = "Aider"
  icon         = "/icon/aider.svg"
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
      echo "Checking dependencies for Linux..."
      
      # Check and install tmux/screen only if needed and requested
      if [ "${var.use_tmux}" = "true" ]; then
        if ! command_exists tmux; then
          echo "Installing tmux for persistent sessions..."
          if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update -qq
            sudo apt-get install -y -qq tmux
          elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y -q tmux
          else
            echo "Warning: Unable to install tmux on this system."
          fi
        else
          echo "tmux is already installed, skipping installation."
        fi
      elif [ "${var.use_screen}" = "true" ]; then
        if ! command_exists screen; then
          echo "Installing screen for persistent sessions..."
          if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update -qq
            sudo apt-get install -y -qq screen
          elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y -q screen
          else
            echo "Warning: Unable to install screen on this system."
          fi
        else
          echo "screen is already installed, skipping installation."
        fi
      fi
    else
      echo "This module currently only supports Linux workspaces."
      exit 1
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
      
      # Check if python3 and pip/venv are installed
      if ! command_exists python3 || ! command_exists pip3; then
        echo "Installing Python dependencies required for Aider..."
        if command -v apt-get >/dev/null 2>&1; then
          sudo apt-get update -qq
          sudo apt-get install -y -qq python3-pip python3-venv
        elif command -v dnf >/dev/null 2>&1; then
          sudo dnf install -y -q python3-pip python3-virtualenv
        else
          echo "Warning: Unable to install Python on this system."
        fi
      else
        echo "Python is already installed, skipping installation."
      fi
      
      # Use official installation script
      if ! command_exists aider; then
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
      
      # Ensure Aider config directory exists
      mkdir -p "$HOME/.config/aider"
      
      # Create the config.yml file with extensions configuration
      cat > "$HOME/.config/aider/config.yml" << EOL
${trimspace(local.combined_extensions)}
EOL
      echo "Added Coder MCP extension to Aider config.yml"
      
      # Create a conventions file that instructs Aider to report tasks
      mkdir -p "${var.folder}"
      cat > "${var.folder}/CONVENTIONS.md" << 'CONVENTIONS_EOF'
${var.experiment_task_conventions}
CONVENTIONS_EOF
      echo "Created CONVENTIONS.md file with task reporting instructions"
    fi

    # Start a persistent session at workspace creation
    echo "Starting persistent Aider session..."
    
    # Create a log file to store session output
    touch "$HOME/.aider.log"
    
    # Set up environment for UTF-8 support
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    
    # Ensure Aider binaries are in PATH
    export PATH="$HOME/bin:$PATH"
    
    if [ "${var.use_tmux}" = "true" ]; then
      # Check if we have a task prompt
      if [ -n "$CODER_MCP_AIDER_TASK_PROMPT" ]; then
        echo "Running Aider with message in tmux session..."
        # Start aider with the message flag and yes-always to avoid confirmations
        tmux new-session -d -s ${var.session_name} -c ${var.folder} "echo \"Starting Aider with app status slug: aider\"; export ANTHROPIC_API_KEY=\"$ANTHROPIC_API_KEY\"; export CODER_MCP_APP_STATUS_SLUG=\"aider\"; aider --architect --yes-always --read CONVENTIONS.md --message \"Report each step to Coder. Your task: $CODER_MCP_AIDER_TASK_PROMPT\""
        echo "Aider task started in tmux session '${var.session_name}'. Check the UI for progress."
      else
        # Create a new detached tmux session for interactive use
        tmux new-session -d -s ${var.session_name} -c ${var.folder} "echo \"Starting Aider with app status slug: aider\"; export ANTHROPIC_API_KEY=\"$ANTHROPIC_API_KEY\"; export CODER_MCP_APP_STATUS_SLUG=\"aider\"; aider --read CONVENTIONS.md"
        echo "Tmux session '${var.session_name}' started. Access it by clicking the Aider button."
      fi
    else
      # Check if we have a task prompt
      if [ -n "$CODER_MCP_AIDER_TASK_PROMPT" ]; then
        echo "Running Aider with message in screen session..."
        
        # Ensure the screenrc exists with multi-user settings
        if [ ! -f "$HOME/.screenrc" ]; then
          echo "Creating ~/.screenrc and adding multiuser settings..."
          echo -e "multiuser on\nacladd $(whoami)" > "$HOME/.screenrc"
        fi
        
        if ! grep -q "^multiuser on$" "$HOME/.screenrc"; then
          echo "Adding 'multiuser on' to ~/.screenrc..."
          echo "multiuser on" >> "$HOME/.screenrc"
        fi

        if ! grep -q "^acladd $(whoami)$" "$HOME/.screenrc"; then
          echo "Adding 'acladd $(whoami)' to ~/.screenrc..."
          echo "acladd $(whoami)" >> "$HOME/.screenrc"
        fi
        
        # Start aider with the message flag and yes-always to avoid confirmations
        screen -U -dmS ${var.session_name} bash -c "
          cd ${var.folder}
          export PATH=\"$HOME/bin:$HOME/.local/bin:$PATH\"
          export ANTHROPIC_API_KEY=\"$ANTHROPIC_API_KEY\"
          export CODER_MCP_APP_STATUS_SLUG=\"aider\"
          echo \"Starting Aider with app status slug: aider\"
          aider --architect --yes-always --read CONVENTIONS.md --message \"Report each step to Coder. Your task: $CODER_MCP_AIDER_TASK_PROMPT\"
          /bin/bash
        "
        
        echo "Aider task started in screen session '${var.session_name}'. Check the UI for progress."
      else
        # Create a new detached screen session for interactive use
        
        # Ensure the screenrc exists with multi-user settings
        if [ ! -f "$HOME/.screenrc" ]; then
          echo "Creating ~/.screenrc and adding multiuser settings..."
          echo -e "multiuser on\nacladd $(whoami)" > "$HOME/.screenrc"
        fi
        
        if ! grep -q "^multiuser on$" "$HOME/.screenrc"; then
          echo "Adding 'multiuser on' to ~/.screenrc..."
          echo "multiuser on" >> "$HOME/.screenrc"
        fi

        if ! grep -q "^acladd $(whoami)$" "$HOME/.screenrc"; then
          echo "Adding 'acladd $(whoami)' to ~/.screenrc..."
          echo "acladd $(whoami)" >> "$HOME/.screenrc"
        fi
        
        screen -U -dmS ${var.session_name} bash -c "
          cd ${var.folder}
          export PATH=\"$HOME/bin:$HOME/.local/bin:$PATH\"
          export ANTHROPIC_API_KEY=\"$ANTHROPIC_API_KEY\"
          export CODER_MCP_APP_STATUS_SLUG=\"aider\"
          echo \"Starting Aider with app status slug: aider\"
          aider --read CONVENTIONS.md
          /bin/bash
        "
        echo "Screen session '${var.session_name}' started. Access it by clicking the Aider button."
      fi
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
    # Explicitly export the status reporting environment variable
    export CODER_MCP_APP_STATUS_SLUG="aider"
    
    # Set up environment for UTF-8 support
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    
    # Check if we should use tmux
    if [ "${var.use_tmux}" = "true" ]; then
      # Check if session exists, attach or create
      if tmux has-session -t ${var.session_name} 2>/dev/null; then
        echo "Attaching to existing Aider tmux session..."
        # Ensure the environment variables are set when attaching
        tmux setenv -t ${var.session_name} CODER_MCP_APP_STATUS_SLUG "aider"
        tmux attach-session -t ${var.session_name}
      else
        echo "Starting new Aider tmux session..."
        tmux new-session -s ${var.session_name} -c ${var.folder} "export ANTHROPIC_API_KEY=\"$ANTHROPIC_API_KEY\"; export CODER_MCP_APP_STATUS_SLUG=\"aider\"; aider --read CONVENTIONS.md; exec bash"
      fi
    elif [ "${var.use_screen}" = "true" ]; then
      # Use screen
      # Check if session exists first
      if ! screen -list | grep -q "${var.session_name}"; then
        echo "Error: No existing Aider session found. Please wait for the script to start it."
        exit 1
      fi
      # Set the environment variable before attaching to the screen session
      export CODER_MCP_APP_STATUS_SLUG="aider"
      # Only attach to existing session
      screen -xRR ${var.session_name}
    else
      # Run directly without a multiplexer
      cd "${var.folder}"
      echo "Starting Aider directly..."
      export CODER_MCP_APP_STATUS_SLUG="aider"
      aider --read CONVENTIONS.md
    fi
  EOT
  order        = var.order
}
