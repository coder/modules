import { describe, expect, it } from "bun:test";
import {
  executeScriptInContainer,
  runTerraformApply,
  runTerraformInit,
  testRequiredVariables,
} from "../test";

describe("jetbrains-gateway`", async () => {
  await runTerraformInit(import.meta.dir);

  await testRequiredVariables(import.meta.dir, {
    agent_id:  "foo",
    agent_name: "bar",
    project_directory: "/baz/",
    jetbrains_ides: "[\"IU\", \"IC\", \"PY\"]",
  });
});
