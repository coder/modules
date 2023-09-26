import { describe, expect, it } from "bun:test";
import {
  executeScriptInContainer,
  runTerraformApply,
  runTerraformInit,
  testRequiredVariables,
} from "../test";

describe("aws-region", async () => {
  await runTerraformInit(import.meta.dir);

  testRequiredVariables(import.meta.dir, {});

  it("default output", async () => {
    const state = await runTerraformApply(import.meta.dir, {});
    expect(state.outputs.value.value).toBe("us-east-1");
  });

  it("customized default", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      default: "us-west-2",
    });
    expect(state.outputs.value.value).toBe("us-west-2");
  });
});
