import { it, expect, describe } from "bun:test";
import {
  runTerraformInit,
  testRequiredVariables,
  executeScriptInContainer,
  runTerraformApply,
} from "../test";

describe("jetbrains-gateway", async () => {
  await runTerraformInit(import.meta.dir);

  await testRequiredVariables(import.meta.dir, {
    agent_id: "foo",
    agent_name: "bar",
    folder: "/baz/",
    jetbrains_ides: '["IU", "IC", "PY"]',
  });

  it("default to first ide", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      agent_name: "bar",
      folder: "/baz/",
      jetbrains_ides: '["IU", "IC", "PY"]',
    });
    expect(state.outputs.jetbrains_ides.value).toBe(
      '["IU","232.9921.47","https://download.jetbrains.com/idea/ideaIU-2023.2.2.tar.gz"]',
    );
  });
});
