import { describe, expect, it } from "bun:test";
import { runTerraformInit, testRequiredVariables } from "../test";

describe("node-via-nvm", async () => {
  await runTerraformInit(import.meta.dir);

  testRequiredVariables(import.meta.dir, {
    agent_id: "foo",
  });

  // More tests depend on shebang refactors
});
