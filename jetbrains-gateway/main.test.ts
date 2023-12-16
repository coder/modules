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
    folder: "/baz/",
  });

  it("default to first ide", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      agent_name: "foo",
      folder: "/baz/",
      jetbrains_ides: '["IU", "GO", "PY"]',
    });
    expect(state.outputs.jetbrains_ides.value).toBe(
      '["IU","232.10203.10","https://download.jetbrains.com/idea/ideaIU-2023.2.4.tar.gz"]',
    );
  });
});
