# Contributing a Module

To quickly start contributing with a new module, clone this repository and run:

```shell
./new.sh MOUDLE_NAME
```

Test a module by running an instance of Coder on your local machine:

```shell
coder server --in-memory
```

This will create a new module in the modules directory with the given name and scaffolding.
Edit the files, adding your module's implementation, documentation and screenshots.

## Testing a Module

Create a template and edit it to include your development module:

> [!NOTE]
> The Docker starter template is recommended for quick-iteration!

```hcl
module "MOUDLE_NAME" {
    source = "/home/user/coder/modules/MOUDLE_NAME"
}
```

You can also test your module by specifying the source as a git repository:

```hcl
module "MOUDLE_NAME" {
    source = "git::https://github.com/<USERNAME>/<REPO>.git//<FOLDER>?ref=<BRANCH>"
}
```

Build a workspace and your module will be consumed! 🥳

Open a pull-request with your module, a member of the Coder team will
manually test it, and after-merge it will appear on the Registry.
