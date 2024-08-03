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
}
```

## Releases

> [!WARNING]
> When creating a new release, make sure that your new version number is fully accurate. If a version number is incorrect or does not exist, we may end up serving incorrect/old data for our various tools and providers.

Much of our release process is automated. To cut a new release:

1. Navigate to [GitHub's Releases page](https://github.com/coder/modules/releases)
2. Click "Draft a new release"
3. Click the "Choose a tag" button and type a new release number in the format `v<major>.<minor>.<patch>` (e.g., `v1.18.0`). Then click "Create new tag".
4. Click the "Generate release notes" button, and clean up the resulting README. Be sure to remove any notes that would not be relevant to end-users (e.g., bumping dependencies).
5. Once everything looks good, click the "Publish release" button.

Once the release has been cut, a script will run to check whether there are any modules that will require that the new release number be published to Terraform. If there are any, a new pull request will automatically be generated. Be sure to approve this PR and merge it into the `main` branch.

Following that, our automated processes will handle publishing new data for [`registry.coder.com`](https://github.com/coder/registry.coder.com/):

1. Publishing new versions to Coder's [Terraform Registry](https://registry.terraform.io/providers/coder/coder/latest)
2. Publishing new data to the [Coder Registry](https://registry.coder.com)

> [!NOTE]
> Some data in `registry.coder.com` is fetched on demand from the Module repo's main branch. This data should be updated almost immediately after a new release, but other changes will take some time to propagate.
