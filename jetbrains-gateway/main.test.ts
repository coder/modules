import { describe } from "bun:test";
import { runTerraformInit, testRequiredVariables } from "../test";

describe("jetbrains-gateway`", async () => {
  await runTerraformInit(import.meta.dir);

  await testRequiredVariables(import.meta.dir, {
    agent_id: "foo",
    agent_name: "bar",
    folder: "/baz/",
    jetbrains_ides: '["IU", "IC", "PY"]',
  });
});
