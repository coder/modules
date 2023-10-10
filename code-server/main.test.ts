import { describe, expect, it } from "bun:test";
import {
  executeScriptInContainer,
  runTerraformApply,
  runTerraformInit,
  testRequiredVariables,
} from "../test";

describe("code-server", async () => {
  await runTerraformInit(import.meta.dir);

  testRequiredVariables(import.meta.dir, {
    agent_id: "foo",
  });
});
