# Contributing

## Getting started

This repo uses the [Bun runtime](https://bun.sh/) to to run all code and tests. To install Bun, you can run this command on Linux/MacOS:

```shell
curl -fsSL https://bun.sh/install | bash
```

Or this command on Windows:

```shell
powershell -c "irm bun.sh/install.ps1 | iex"
```

Follow the instructions to ensure that Bun is available globally. Once Bun has been installed, clone this repository. From there, run this script to create a new module:

```shell
./new.sh NAME_OF_NEW_MODULE
```

## Testing a Module

> **Note:** It is the responsibility of the module author to implement tests for their module. The author must test the module locally before submitting a PR.

A suite of test-helpers exists to run `terraform apply` on modules with variables, and test script output against containers.

The testing suite must be able to run docker containers with the `--network=host` flag. This typically requires running the tests on Linux as this flag does not apply to Docker Desktop for MacOS and Windows. MacOS users can work around this by using something like [colima](https://github.com/abiosoft/colima) or [Orbstack](https://orbstack.dev/) instead of Docker Desktop.

Reference the existing `*.test.ts` files to get an idea for how to set up tests.

You can run all tests in a specific file with this command:

```shell
$ bun test -t '<module>'
```

Or run all tests by running this command:

```shell
$ bun test
```

You can test a module locally by updating the source as follows

```tf
module "example" {
  source = "git::https://github.com/<USERNAME>/<REPO>.git//<MODULE-NAME>?ref=<BRANCH-NAME>"
  # You may need to remove the 'version' field, it is incompatible with some sources.
}
```

## Releases

> [!WARNING]
> When creating a new release, make sure that your new version number is fully accurate. If a version number is incorrect or does not exist, we may end up serving incorrect/old data for our various tools and providers.

The release process is automated and follows these steps:

1. Create a PR with your changes
2. Update the version in the module's README.md file with the next version.
3. The CI will automatically check that the version in README.md is updated
4. Once the PR is approved and merged to main:
   - The changes will be available on the main branch
   - You can then push a new tag for the module from main
   - The tag should follow the format: `release/module-name/v1.0.0`


Following that, our automated processes will handle publishing new data to [`registry.coder.com`](https://registry.coder.com):

> [!NOTE]
> Some data in `registry.coder.com` is fetched on demand from the Module repo's main branch. This data should be updated almost immediately after a new release, but other changes will take some time to propagate.
