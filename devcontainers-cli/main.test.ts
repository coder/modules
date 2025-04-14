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

const executeScriptInContainerWithPackageManager = async (
  state: TerraformState,
  image: string,
  packageManager: string,
  shell = "sh",
): Promise<{
  exitCode: number;
  stdout: string[];
  stderr: string[];
}> => {
  const instance = findResourceInstance(state, "coder_script");
  const id = await runContainer(image);

  // Install the specified package manager
  if (packageManager === "npm") {
    await execContainer(id, [shell, "-c", "apk add nodejs npm"]);
  } else if (packageManager === "pnpm") {
    await execContainer(id, [shell, "-c", "apk add nodejs npm && npm install -g pnpm"]);
  } else if (packageManager === "yarn") {
    await execContainer(id, [shell, "-c", "apk add nodejs npm && npm install -g yarn"]);
  }

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

  it("misses all package managers", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "some-agent-id",
    });
    const output = await executeScriptInContainer(state, "alpine");
    expect(output.exitCode).toBe(1);
    expect(output.stdout).toEqual([
      "No supported package manager (npm, pnpm, yarn) is installed. Please install one first.",
    ]);
  });

  it("installs devcontainers-cli with npm", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "some-agent-id",
    });

    const output = await executeScriptInContainerWithPackageManager(state, "alpine", "npm");
    expect(output.exitCode).toBe(0);

    expect(output.stdout[0]).toEqual("Installing @devcontainers/cli using npm ...");
    expect(output.stdout[output.stdout.length-1]).toEqual("🥳 @devcontainers/cli has been installed into /usr/local/bin/devcontainer!");
  });

  it("installs devcontainers-cli with yarn", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "some-agent-id",
    });

    const output = await executeScriptInContainerWithPackageManager(state, "alpine", "yarn");
    expect(output.exitCode).toBe(0);

    expect(output.stdout[0]).toEqual("Installing @devcontainers/cli using yarn ...");
    expect(output.stdout[output.stdout.length-1]).toEqual("🥳 @devcontainers/cli has been installed into /usr/local/bin/devcontainer!");
  });
});