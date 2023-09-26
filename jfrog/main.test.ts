import { describe, expect, it } from "bun:test";
import {
  executeScriptInContainer,
  runTerraformApply,
  runTerraformInit,
  testRequiredVariables,
} from "../test";

describe("jfrog", async () => {
  await runTerraformInit(import.meta.dir);

  testRequiredVariables(import.meta.dir, {
    agent_id: "some-agent-id",
    jfrog_host: "YYYY.jfrog.io",
    artifactory_access_token: "XXXX",
    package_managers: '',
  });
});
