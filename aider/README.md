---
display_name: Aider
description: Run Aider AI pair programming in your workspace
icon: ../.icons/terminal.svg
maintainer_github: coder
verified: false
tags: [ai, pair-programming, coding-assistant]
---

# Aider

Run [Aider](https://aider.chat) AI pair programming in your workspace. This module installs Aider and provides a persistent session using screen or tmux.

```tf
module "aider" {
  source       = "registry.coder.com/modules/aider/coder"
  version      = "1.0.0"
  agent_id     = coder_agent.example.id
  folder       = "/home/coder"
  use_tmux     = false
  session_name = "aider"
}
```

## Features

- **Interactive Parameter Selection**: Choose your AI provider, model, and configuration options when creating the workspace
- **Multiple AI Providers**: Supports Anthropic (Claude), OpenAI, DeepSeek, GROQ, and OpenRouter
- **Persistent Sessions**: Uses screen (default) or tmux to keep Aider running in the background
- **Optional Dependencies**: Install Playwright for web page scraping and PortAudio for voice coding
- **Project Integration**: Works with any project directory, including Git repositories
- **Browser UI**: Use Aider in your browser with a modern web interface instead of the terminal

## Module Parameters

| Parameter | Description | Type | Default |
|-----------|-------------|------|---------|
| `agent_id` | The ID of a Coder agent (required) | `string` | - |
| `folder` | The folder to run Aider in | `string` | `/home/coder` |
| `install_aider` | Whether to install Aider | `bool` | `true` |
| `use_screen` | Whether to use screen for running Aider in the background | `bool` | `true` |
| `use_tmux` | Whether to use tmux instead of screen for running Aider in the background | `bool` | `false` |
| `session_name` | Name for the persistent session (screen or tmux) | `string` | `"aider"` |
| `order` | Position of the app in the UI presentation | `number` | `null` |

## Usage Examples

### Basic setup

```tf
module "aider" {
  source        = "registry.coder.com/modules/aider/coder"
  version       = "1.0.0"
  agent_id      = coder_agent.main.id
}
```

### With API key via environment variables

```tf
variable "anthropic_api_key" {
  type        = string
  description = "The Anthropic API key"
  sensitive   = true
}

resource "coder_agent" "main" {
  # ...
  env = {
    ANTHROPIC_API_KEY = var.anthropic_api_key
  }
}

module "aider" {
  source  = "registry.coder.com/modules/aider/coder"
  version = "1.0.0"
  agent_id = coder_agent.main.id
}
```

### With tmux instead of screen

```tf
module "aider" {
  source        = "registry.coder.com/modules/aider/coder"
  version       = "1.0.0"
  agent_id      = coder_agent.main.id
  use_tmux      = true
  session_name  = "aider-session"
}
```

## Complete Template Example

Here's a complete example of how to use the Aider module in a Coder template:

```tf
terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
      version = "0.11.0"
    }
  }
}

provider "coder" {}

data "coder_workspace" "me" {}

resource "coder_agent" "main" {
  os             = "linux"
  arch           = "amd64"
  startup_script = <<-EOT
    #!/bin/bash
    # Add any additional workspace setup here
    echo "Workspace ready!"
  EOT
}

resource "coder_app" "code-server" {
  agent_id     = coder_agent.main.id
  slug         = "code-server"
  display_name = "VS Code"
  url          = "http://localhost:8080/?folder=/home/coder/project"
  icon         = "/icon/code.svg"
  subdomain    = true
  share        = "owner"

  healthcheck {
    url       = "http://localhost:8080/healthz"
    interval  = 3
    threshold = 10
  }
}

module "aider" {
  source   = "registry.coder.com/modules/aider/coder"
  version  = "1.0.0"
  agent_id = coder_agent.main.id
  folder   = "/home/coder"
}

resource "coder_metadata" "workspace_info" {
  resource_id = coder_agent.main.id
  item {
    key   = "AI Assistant"
    value = "Aider"
  }
}
```

## Using Aider in Your Workspace

After the workspace starts, Aider will be installed and configured according to your parameters. A persistent session will automatically be started during workspace creation.

### Accessing Aider

Click the "Aider" button in the Coder dashboard to access Aider:

- You'll be attached to the persistent session that was created during workspace setup
- The session maintains context even when you disconnect

### Persistent Sessions

Aider runs in persistent sessions that start automatically when the workspace is created:

- **Screen**: By default, screen is used for persistent sessions (session name: "aider")
- **Tmux**: Alternatively, you can enable tmux instead of screen (session name: "aider")

This allows you to:

- Disconnect and reconnect to your Aider session without losing context
- Run Aider in the background while doing other work
- Switch between terminal and browser interfaces

### Available AI Providers and Models

| Provider | Available Models | Description |
|----------|------------------|-------------|
| **Anthropic** | Claude 3.7 Sonnet, Claude 3.7 Haiku | High-quality Claude models |
| **OpenAI** | o3-mini, o1, GPT-4o | GPT models from OpenAI |
| **DeepSeek** | DeepSeek R1, DeepSeek Chat V3 | Models from DeepSeek |
| **GROQ** | Mixtral, Llama 3 | Fast inference on open models |
| **OpenRouter** | OpenRouter | Access to multiple providers with a single key |

### API Keys

You will need an API key for your selected provider:

- **Anthropic**: Get a key from [console.anthropic.com](https://console.anthropic.com/)
- **OpenAI**: Get a key from [platform.openai.com](https://platform.openai.com/api-keys)
- **DeepSeek**: Get a key from [platform.deepseek.com](https://platform.deepseek.com/)
- **GROQ**: Get a key from [console.groq.com](https://console.groq.com/keys)
- **OpenRouter**: Get a key from [openrouter.ai](https://openrouter.ai/keys)

You can use the Coder dotenv module to configure Aider if needed.

## Troubleshooting

If you encounter issues:

1. **Screen/Tmux issues**: If you can't reconnect to your session, check if the session exists with `screen -list` or `tmux list-sessions`
2. **API key issues**: Ensure you've entered the correct API key for your selected provider
3. **Browser mode issues**: If the browser interface doesn't open, check that you're accessing it from a machine that can reach your Coder workspace

For more information on using Aider, see the [Aider documentation](https://aider.chat/docs/).
