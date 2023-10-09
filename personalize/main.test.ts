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

//   it("runs with personalize script", async () => {
//     const state = await runTerraformApply(import.meta.dir, {
//       agent_id: "foo",
//     });
//     const instance = findResourceInstance(state, "coder_script");
//     const id = await runContainer("alpine");
//     const resp = await execContainer(id, ["sh", "-c", "touch ~/personalize && echo \"echo test\" > ~/personalize && chmod +x ~/personalize &&" + instance.script]);
//     const stdout = resp.stdout.trim().split("\n");
//     console.log("====== resp ==== stdout (", resp.exitCode, "):");
//     console.log(resp.stdout);
//     console.log("====== resp ==== stderr:");
//     console.log(resp.stderr);
//     console.log("======");
//     // const stderr = resp.stderr.trim().split("\n");
//     expect(resp.exitCode).toBe(0);
//     expect(stdout).toEqual([""]);
//   });
});
