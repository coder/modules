import { describe, expect, it } from "bun:test";
import {
  executeScriptInContainer,
  runTerraformApply,
  runTerraformInit,
  testRequiredVariables,
} from "../test";

describe("azure-region", async () => {
  await runTerraformInit(import.meta.dir);

  testRequiredVariables(import.meta.dir, {});

  it("default output", async () => {
    const state = await runTerraformApply(import.meta.dir, {});
    expect(state.outputs.value.value).toBe("ams");
  });

  it("customized default", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      default: "atl",
    });
    expect(state.outputs.value.value).toBe("atl");
  });
});
