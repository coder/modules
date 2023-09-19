# Modules

Modules extend Workspaces to provide self-contained building-blocks on your development environment.

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
