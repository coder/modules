---
name: code-server
description: Install and run VS Code in the web browser
tags: [ide, vscode, os-linux, os-macos]
icon: /icon/code.svg
---

# code-server Module

Install and run VS Code in the web browser

![code-server demo](https://user-images.githubusercontent.com/22407953/268563523-dbc1ff10-4772-4d33-a625-aee0b18909cc.gif))

## Requirements

- Linux or macOS template

## Usage instructions

Add the following block to your [Coder template](https://coder.com/docs/v2/latest/templates):

```hcl
module "code-server" {
    source = "https://github.com/coder/coder//code-server/"
    agent = coder_agent.main.id # your agent ID
}
```