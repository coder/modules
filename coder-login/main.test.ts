import { describe } from "bun:test";
import { runTerraformInit, testRequiredVariables } from "../test";

describe("coder-login", async () => {
  await runTerraformInit(import.meta.dir);

  testRequiredVariables(import.meta.dir, {
    agent_id: "foo",
  });
});
