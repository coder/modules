import { describe, expect, it } from "bun:test";
import {
  executeScriptInContainer,
  runTerraformApply,
  runTerraformInit,
  testRequiredVariables,
  findResourceInstance,
  runContainer,
  TerraformState,
  execContainer,
} from "../test";

// executes the coder script after installing pip
const executeScriptInContainerWithPip = async (
  state: TerraformState,
  image: string,
  shell: string = "sh",
): Promise<{
  exitCode: number;
  stdout: string[];
  stderr: string[];
}> => {
  const instance = findResourceInstance(state, "coder_script");
  const id = await runContainer(image);
  const respPipx = await execContainer(id, [shell, "-c", "apk add pipx"]);
  const resp = await execContainer(id, [shell, "-c", instance.script]);
  const stdout = resp.stdout.trim().split("\n");
  const stderr = resp.stderr.trim().split("\n");
  return {
    exitCode: resp.exitCode,
    stdout,
    stderr,
  };
};

describe("jupyterlab", async () => {
  await runTerraformInit(import.meta.dir);

  testRequiredVariables(import.meta.dir, {
    agent_id: "foo",
  });

  it("fails without pipx", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
    });
    const output = await executeScriptInContainer(state, "alpine");
    expect(output.exitCode).toBe(1);
    expect(output.stdout).toEqual([
      "\u001B[0;1mInstalling jupyterlab!",
      "pipx is not installed",
      "Please install pipx in your Dockerfile/VM image before running this script",
    ]);
  });

  // TODO: Add faster test to run with pipx.
  // currently times out.
  // it("runs with pipx", async () => {
  //   ...
  //   const output = await executeScriptInContainerWithPip(state, "alpine");
  //   ...
  // });
});
