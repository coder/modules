import { describe, expect, it } from "bun:test";
import {
  execContainer,
  executeScriptInContainer,
  findResourceInstance,
  runContainer,
  runTerraformApply,
  runTerraformInit,
  testRequiredVariables,
  type TerraformState,
} from "../test";

// executes the coder script after installing pip
const executeScriptInContainerWithPipx = async (
  state: TerraformState,
  image: string,
  shell = "sh",
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

// executes the coder script after installing uv
const executeScriptInContainerWithUv = async (
  state: TerraformState,
  image: string,
  shell = "sh",
): Promise<{
  exitCode: number;
  stdout: string[];
  stderr: string[];
}> => {
  const instance = findResourceInstance(state, "coder_script");
  const id = await runContainer(image);
  const respPipx = await execContainer(id, [
    shell,
    "-c",
    "apk --no-cache add uv gcc musl-dev linux-headers && uv venv",
  ]);
  const resp = await execContainer(id, [shell, "-c", instance.script]);
  const stdout = resp.stdout.trim().split("\n");
  const stderr = resp.stderr.trim().split("\n");
  return {
    exitCode: resp.exitCode,
    stdout,
    stderr,
  };
};

describe("marimo", async () => {
  await runTerraformInit(import.meta.dir);

  testRequiredVariables(import.meta.dir, {
    agent_id: "foo",
  });

  it("fails without installers", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
    });
    const output = await executeScriptInContainer(state, "alpine");
    expect(output.exitCode).toBe(1);
    expect(output.stdout).toEqual([
      "Checking for a supported installer",
      "No valid installer is not installed",
      "Please install pipx or uv in your Dockerfile/VM image before running this script",
    ]);
  });

});