import { readableStreamToText, spawn } from "bun";
import { describe, expect, it } from "bun:test";
import {
  executeScriptInContainer,
  runTerraformApply,
  runTerraformInit,
  testRequiredVariables,
  runContainer,
  execContainer,
  findResourceInstance
} from "../test";

describe("personalize", async () => {
  await runTerraformInit(import.meta.dir);

  testRequiredVariables(import.meta.dir, {
    agent_id: "foo",
  });

  it("warns without personalize script", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
    });
    const output = await executeScriptInContainer(state, "alpine");
    expect(output.exitCode).toBe(0);
    expect(output.stdout).toEqual([
      "✨ \u001b[0;1mYou don't have a personalize script!",
      "",
      "Run \u001b[36;40;1mtouch ~/personalize && chmod +x ~/personalize\u001b[0m to create one.",
      "It will run every time your workspace starts. Use it to install personal packages!"
    ]);
  });

  it("runs with personalize script", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
    });
    const instance = findResourceInstance(state, "coder_script");
    const id = await runContainer("alpine");
    const respInit = await execContainer(id, ["sh", "-c", "touch ~/personalize && echo \"echo test\" > ~/personalize && chmod +x ~/personalize && echo \"completed touch cmds\""]);
    
    console.log("\n id  =  ", id, "\n")
    
    console.log("\n====== init ==== stdout (", respInit.exitCode, "):");
    console.log(respInit.stdout);
    console.log("====== init ==== stderr:");
    console.log(respInit.stderr);
    console.log("======");
    const resp = await execContainer(id, ["sh", "-c", instance.script]);
    console.log("====== resp ==== stdout (", resp.exitCode, "):");
    console.log(resp.stdout);
    console.log("====== resp ==== stderr:");
    console.log(resp.stderr);
    console.log("======");
    // await new Promise((resolve) => setTimeout(resolve, 100000000000));
    const stdout = resp.stdout.trim().split("\n");
    const stderr = resp.stderr.trim().split("\n");
    expect(resp.exitCode).toBe(0);
    expect(stdout).toEqual([""]);
  });
});
