import { serve } from "bun";
import { describe } from "bun:test";
import {
  createJSONResponse,
  runTerraformInit,
  testRequiredVariables,
} from "../test";

describe("jfrog-oauth", async () => {
  await runTerraformInit(import.meta.dir);

  testRequiredVariables(import.meta.dir, {
    agent_id: "some-agent-id",
    jfrog_url: "http://localhost:8081",
    package_managers: "{}",
  });
});

//TODO add more tests
