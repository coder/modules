import { beforeAll, describe, expect, it, test } from "bun:test";
import {
  executeScriptInContainer,
  runTerraformApply,
  runTerraformInit,
  testRequiredVariables,
} from "../test";

type TestVariables = Readonly<{
  agent_id: string;
  resource_id: string;
  admin_username?: string;
  admin_password?: string;
}>;

describe("Web RDP", () => {
  beforeAll(async () => {
    await runTerraformInit(import.meta.dir);
    testRequiredVariables(import.meta.dir, {
      agent_id: "foo",
      resource_id: "bar",
    });
  });

  it("Patches the Devolutions Angular app's .html file (after it has been bundled) to include an import for the custom JS file", async () => {
    const state = await runTerraformApply<TestVariables>(import.meta.dir, {
      agent_id: "foo",
      resource_id: "bar",
    });

    throw new Error("Not implemented yet");
  });

  it("Injects the Terraform username and password into the JS patch file", async () => {
    throw new Error("Not implemented yet");

    // Test that things work with the default username/password
    const defaultState = await runTerraformApply<TestVariables>(
      import.meta.dir,
      {
        agent_id: "foo",
        resource_id: "bar",
      },
    );

    const output = await executeScriptInContainer(defaultState, "alpine");

    // Test that custom usernames/passwords are also forwarded correctly
    const customUsername = "crouton";
    const customPassword = "VeryVeryVeryVeryVerySecurePassword97!";
    const customizedState = await runTerraformApply<TestVariables>(
      import.meta.dir,
      {
        agent_id: "foo",
        resource_id: "bar",
        admin_username: customUsername,
        admin_password: customPassword,
      },
    );
  });
});
