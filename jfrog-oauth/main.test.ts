/**
 * @todo Add more tests
 */
import { describe } from "bun:test";
import { runTerraformInit, testRequiredVariables } from "../test";

describe("jfrog-oauth", async () => {
  await runTerraformInit(import.meta.dir);

  testRequiredVariables(import.meta.dir, {
    agent_id: "some-agent-id",
    jfrog_url: "http://localhost:8081",
    package_managers: "{}",
  });
});
