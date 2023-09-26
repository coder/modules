# Contributing

To create a new module, clone this repository and run:

```shell
./new.sh MOUDLE_NAME
```

## Testing a Module

A suite of test-helpers exists to run `terraform apply` on modules with variables, and test script output against containers.

Reference existing `*.test.ts` files for implementation.

```shell
# Run tests for a specific module!
$ bun test -t '<module>'
```

You can test a module locally by updating the source as follows

```hcl
source = "git::https://github.com/<USERNAME>/<REPO>.git//<MODULE-NAME>?ref=<BRANCH-NAME>"
```
> **Note:** This is the responsibility of the module author to implement tests for their module. and test the module locally before submitting a PR.
