---
display_name: Goose
description: Run Goose in your workspace
icon: ../.icons/goose.svg
maintainer_github: coder
verified: true
tags: [agent, goose]
---

# Goose

Run the [Goose](https://block.github.io/goose/) agent in your workspace to generate code and perform tasks.

### Prerequisites

- `screen` must be installed in your workspace to run Goose in the background

## Examples

Your workspace must have `screen` installed to use this.

### Run in the background and report tasks (Experimental)

```tf
variable "anthropic_api_key" {
  type        = string
  description = "The Anthropic API key"
  sensitive   = true
}

data "coder_parameter" "ai_prompt" {
  type        = "string"
  name        = "AI Prompt"
  default     = ""
  description = "Write a prompt for Goose"
  mutable     = true
}

# Set the prompt and system prompt for Goose via environment variables
resource "coder_agent" "main" {
  # ...
  env = {
    GOOSE_TASK_PROMPT = data.coder_parameter.ai_prompt.value
    SYSTEM_PROMPT      =<<-EOT
      You are a helpful assistant that can help with code.
    EOT

    # An API key is required for experiment_auto_configure
    # See https://block.github.io/goose/docs/getting-started/providers
    ANTHROPIC_API_KEY = var.anthropic_api_key
  }
}

module "goose" {
  count               = data.coder_workspace.me.start_count
  source              = "registry.coder.com/modules/goose/coder"
  version             = "1.0.29"
  agent_id            = coder_agent.example.id
  folder              = "/home/coder"
  install_goose       = true
  goose_version       = "v1.0.16"

  # Enable experimental features
  experiment_report_tasks   = true

  # Avoid configuring Goose manually
  experiment_auto_configure = true

  # Required for experiment_auto_configure
  experiment_goose_provider = "anthropic"
  experiment_goose_model    = "claude-3-5-sonnet-latest"
}
```

## Run standalone

Run Goose as a standalone app in your workspace. This will install Goose and run it directly without using screen or any task reporting to the Coder UI.

```tf
module "goose" {
  source              = "registry.coder.com/modules/goose/coder"
  version             = "1.0.29"
  agent_id            = coder_agent.example.id
  folder              = "/home/coder"
  install_goose       = true
  goose_version       = "v1.0.16"

  # Icon is not available in Coder v2.20 and below, so we'll use a custom icon URL
  icon                = "https://raw.githubusercontent.com/block/goose/refs/heads/main/ui/desktop/src/images/icon.svg"
}
```