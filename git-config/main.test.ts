import { describe, expect, it } from "bun:test";
import {
  executeScriptInContainer,
  runTerraformApply,
  runTerraformInit,
  testRequiredVariables,
} from "../test";

describe("git-config", async () => {
  await runTerraformInit(import.meta.dir);

  testRequiredVariables(import.meta.dir, {
    agent_id: "foo",
  });

  it("fails without git", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
    });
    const output = await executeScriptInContainer(state, "alpine");
    expect(output.exitCode).toBe(1);
    expect(output.stdout).toEqual([
      "\u001B[0;1mChecking git-config!",
      "Git is not installed!",
    ]);
  });

  it("runs with git", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
    });
    const output = await executeScriptInContainer(state, "alpine/git");
    expect(output.exitCode).toBe(0);
    expect(output.stdout).toEqual([
      "\u001B[0;1mChecking git-config!",
      "git-config: No user.email found, setting to ",
      "git-config: No user.name found, setting to default",
      "",
      "\u001B[0;1mgit-config: using email: ",
      "\u001B[0;1mgit-config: using username: default",
    ]);
  });
});
