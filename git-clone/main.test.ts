import { describe, expect, it } from "bun:test";
import {
  executeScriptInContainer,
  runTerraformApply,
  runTerraformInit,
  testRequiredVariables,
} from "../test";

describe("git-clone", async () => {
  await runTerraformInit(import.meta.dir);

  testRequiredVariables(import.meta.dir, {
    agent_id: "foo",
    url: "foo",
  });

  it("fails without git", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      url: "some-url",
    });
    const output = await executeScriptInContainer(state, "alpine");
    expect(output.exitCode).toBe(1);
    expect(output.stdout).toEqual(["Git is not installed!"]);
  });

  it("runs with git", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      url: "fake-url",
    });
    const output = await executeScriptInContainer(state, "alpine/git");
    expect(output.exitCode).toBe(128);
    expect(output.stdout).toEqual([
      "Creating directory ~/fake-url...",
      "Cloning fake-url to ~/fake-url...",
    ]);
  });
});
