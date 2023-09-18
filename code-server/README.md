---
display_name: code-server
description: VS Code in the browser
icon: ../.icons/code.svg
maintainer_github: coder
verified: true
tags: [helper, ide]
---

# code-server

Run [VS Code](https://github.com/Microsoft/vscode) on any machine anywhere and
access it in the browser.

![Screenshot 1](https://github.com/coder/code-server/raw/main/docs/assets/screenshot-1.png?raw=true)
![Screenshot 2](https://github.com/coder/code-server/raw/main/docs/assets/screenshot-2.png?raw=true)

## Highlights

- Code on any device with a consistent development environment
- Use cloud servers to speed up tests, compilations, downloads, and more
- Preserve battery life when you're on the go; all intensive tasks run on your
  server

## Examples

### Extensions

Automatically install extensions from [OpenVSX](https://open-vsx.org/):

```hcl
module "code-server" {
    source = "https://registry.coder.com/modules/code-server"
    extensions = [
        "
    ]
}
```

Enter the `<author>.<name>` into the extensions array and code-server will automatically install on start.

### Settings

Pre-configure code-server with settings:

```hcl
module "settings" {
    source = "https://registry.coder.com/modules/code-server"
    extensions = [ "dracula-theme.theme-dracula" ]
    settings = {
        "workbench.colorTheme" = "Dracula"
    }
}
```

### Offline Mode

Just run code-server in the background, don't fetch it from GitHub:

```hcl
module "settings" {
    source = "https://registry.coder.com/modules/code-server"
    offline = true
}
```