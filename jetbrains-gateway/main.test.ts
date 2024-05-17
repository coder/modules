import { it, expect, describe } from "bun:test";
import {
  runTerraformInit,
  testRequiredVariables,
  runTerraformApply,
} from "../test";

describe("jetbrains-gateway", async () => {
  await runTerraformInit(import.meta.dir);

  await testRequiredVariables(import.meta.dir, {
    agent_id: "foo",
    agent_name: "foo",
    folder: "/home/foo",
  });

  it("default to first ide", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      agent_name: "foo",
      folder: "/home/foo",
      jetbrains_ides: '["IU", "GO", "PY"]',
    });
    expect(state.outputs.identifier.value).toBe("IU");
  });
});
