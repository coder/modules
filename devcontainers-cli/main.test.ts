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

const executeScriptInContainerWithNPM = async (
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
  const respPipx = await execContainer(id, [shell, "-c", "apk add nodejs npm"]);
  const resp = await execContainer(id, [shell, "-c", instance.script]);
  const stdout = resp.stdout.trim().split("\n");
  const stderr = resp.stderr.trim().split("\n");
  return {
    exitCode: resp.exitCode,
    stdout,
    stderr,
  };
};

describe("devcontainers-cli", async () => {
  await runTerraformInit(import.meta.dir);

  testRequiredVariables(import.meta.dir, {
    agent_id: "some-agent-id",
  });

  it("misses npm", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "some-agent-id",
    });
    const output = await executeScriptInContainer(state, "alpine");
    expect(output.exitCode).toBe(1);
    expect(output.stdout).toEqual([
      "Installing @devcontainers/cli ...",
      "npm is not installed, please install npm first",
    ]);
  });

  it("installs devcontainers-cli", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "some-agent-id",
    });

    const output = await executeScriptInContainerWithNPM(state, "alpine");
    expect(output.exitCode).toBe(0);

    expect(output.stdout[0]).toEqual("Installing @devcontainers/cli ...");
    expect(output.stdout[1]).toEqual(
      "Running npm install -g @devcontainers/cli ...",
    );
    expect(output.stdout[4]).toEqual(
      "🥳 @devcontainers/cli has been installed !",
    );
  });
});
