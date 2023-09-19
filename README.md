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

## Registry

Check out the [Coder Registry](https://registry.coder.com) for instructions to integrate modules into your template.

## Contributing a Module

To quickly start contributing with a new module, clone this repository and run:

```sh
./new.sh
```

Test a module by running an instance of Coder on your local machine:

```bash
$ coder server --in-memory
```

Create a template and edit it to include your development module:

> *Info*
> The Docker starter template is recommended for quick-iteration!

```tf
module "testing" {
    source = "/home/user/coder/modules/my-new-module"
}
```

Build a workspace and your module will be consumed! 🥳

Open a pull-request with your module, a member of the Coder team will
manually test it, and after-merge it will appear on the Registry.
