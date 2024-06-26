import { describe, expect, it, test } from "bun:test";
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

describe("Web RDP", async () => {
  await runTerraformInit(import.meta.dir);
  testRequiredVariables<TestVariables>(import.meta.dir, {
    agent_id: "foo",
    resource_id: "bar",
  });

  it("Installs the Devolutions Gateway Angular app locally on the machine", async () => {
    const state = await runTerraformApply<TestVariables>(import.meta.dir, {
      agent_id: "foo",
      resource_id: "bar",
    });

    throw new Error("Not implemented yet");
  });

  /**
   * @todo Verify that the HTML file has been modified, and that the JS file is
   * also part of the file system
   */
  it("Patches the Devolutions Angular app's .html file to include an import for the custom JS file", async () => {
    const state = await runTerraformApply<TestVariables>(import.meta.dir, {
      agent_id: "foo",
      resource_id: "bar",
    });

    throw new Error("Not implemented yet");
  });

  it("Injects Terraform's username and password into the JS patch file", async () => {
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
