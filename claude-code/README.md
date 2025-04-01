---
display_name: Claude Code
description: Run Claude Code in your workspace
icon: ../.icons/claude.svg
maintainer_github: coder
verified: true
tags: [agent, claude-code]
---

# Claude Code

Run the [Claude Code](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview) agent in your workspace to generate code and perform tasks.

### Prerequisites

- Node.js and npm must be installed in your workspace to install Claude Code
- `screen` must be installed in your workspace to run Claude Code in the background

## Examples

### Run in the background and report tasks (Experimental)

> This functionality is in early access and subject to change. Do not run in
> production as it is unstable. Instead, deploy these changes into a demo or
> staging environment.
>
> Join our [Discord channel](https://discord.gg/coder) or
> [contact us](https://coder.com/contact) to get help or share feedback.

Your workspace must have `screen` installed to use this.

```tf
data "coder_parameter" "ai_prompt" {
  type        = "string"
  name        = "AI Prompt"
  default     = ""
  description = "Write a prompt for Claude Code"
  mutable     = true
}

# Set the prompt and system prompt for Claude Code via environment variables
resource "coder_agent" "main" {
  # ...
  env = {
    CLAUDE_TASK_PROMPT = data.coder_parameter.ai_prompt.value
    SYSTEM_PROMPT      = <<-EOT
      You are a helpful assistant that can help with code.
    EOT
  }
}

module "claude-code" {
  count               = data.coder_workspace.me.start_count
  source              = "registry.coder.com/modules/claude-code/coder"
  version             = "1.0.29"
  agent_id            = coder_agent.example.id
  folder              = "/home/coder"
  install_claude_code = true
  claude_code_version = "0.2.57"

  # Enable experimental features
  experiment_use_screen          = true
  experiment_report_tasks        = true
}
```

## Run standalone

Run Claude Code as a standalone app in your workspace. This will install Claude Code and run it directly without using screen or any task reporting to the Coder UI.

```tf
module "claude-code" {
  source              = "registry.coder.com/modules/claude-code/coder"
  version             = "1.0.29"
  agent_id            = coder_agent.example.id
  folder              = "/home/coder"
  install_claude_code = true
  claude_code_version = "latest"

  # Icon is not available in Coder v2.20 and below, so we'll use a custom icon URL
  icon                = "https://registry.npmmirror.com/@lobehub/icons-static-png/1.24.0/files/dark/claude-color.png"
}
```