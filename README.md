<div align="center">
  <h1>
  Modules
  </h1>

[Registry](https://registry.coder.com) | [Coder Docs](https://coder.com/docs) | [Why Coder](https://coder.com/why) | [Coder Enterprise](https://coder.com/docs/v2/latest/enterprise)

[![discord](https://img.shields.io/discord/747933592273027093?label=discord)](https://discord.gg/coder)
[![license](https://img.shields.io/github/license/coder/modules)](./LICENSE)

</div>

Modules extend Templates to create reusable components for your development environment.

e.g.

```hcl
module "code-server" {
    source = "https://registry.coder.com/modules/code-server"
    agent_id = coder_agent.main.id
}
```

- [code-server](https://registry.coder.com/modules/code-server): Install on start, create an app to access via the dashboard, install extensions, and pre-configure editor settings.
- [personalize](https://registry.coder.com/modules/personalize): Run a script on workspace start that allows developers to run custom commands to personalize their workspace.
- [VS Code Desktop](https://registry.coder.com/modules/vscode-desktop): Add a button to open any workspace in VS Code with a single click.
- [JetBrains Gateway](https://registry.coder.com/modules/jetbrains-gateway): Display a button to launch JetBrains Gateway IDEs in the dashboard.

## Registry

Check out the [Coder Registry](https://registry.coder.com) for instructions to integrate modules into your template.

# Contructing a Module

See the [CONTRIBUTING.md](./CONTRIBUTING.md) file for instructions on how to construct and publish your own module to the Coder Registry.
