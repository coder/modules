import { describe, expect, it } from "bun:test";
import {
  executeScriptInContainer,
  runTerraformApply,
  runTerraformInit,
  testRequiredVariables,
} from "../test";

describe("exoscale-zone", async () => {
  await runTerraformInit(import.meta.dir);

  testRequiredVariables(import.meta.dir, {});

  it("default output", async () => {
    const state = await runTerraformApply(import.meta.dir, {});
    expect(state.outputs.value.value).toBe("");
  });

  it("customized default", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      default: "at-vie-1",
    });
    expect(state.outputs.value.value).toBe("at-vie-1");
  });
});
