import { describe, expect, it, test } from "bun:test";
import {
  TerraformState,
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

/**
 * @todo It would be nice if we had a way to verify that the Devolutions root
 * HTML file is modified to include the import for the patched Coder script,
 * but the current test setup doesn't really make that viable
 */
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

  it("Injects Terraform's username and password into the JS patch file", async () => {
    const findInstancesScript = (state: TerraformState): string | null => {
      for (const resource of state.resources) {
        if (resource.type !== "coder_script") {
          continue;
        }

        for (const instance of resource.instances) {
          if (instance.attributes.display_name === "windows-rdp") {
            return instance.attributes.script as string;
          }
        }
      }

      return null;
    };

    /**
     * Using a regex as a quick-and-dirty way to get at the username and
     * password values.
     *
     * Tried going through the trouble of extracting out the form entries
     * variable from the main output, converting it from Prettier/JS-based JSON
     * text to universal JSON text, and exposing it as a parsed JSON value. That
     * got to be a bit too much, though.
     *
     * Written and tested via Regex101
     * @see {@link https://regex101.com/r/UMgQpv/2}
     */
    const formEntryValuesRe =
      /^const formFieldEntries = \{$.*?^\s+username: \{$.*?^\s*?querySelector.*?,$.*?^\s*value: "(?<username>.+?)",$.*?password: \{$.*?^\s+querySelector: .*?,$.*?^\s*value: "(?<password>.+?)",$.*?^};$/ms;

    // Test that things work with the default username/password
    const defaultState = await runTerraformApply<TestVariables>(
      import.meta.dir,
      {
        agent_id: "foo",
        resource_id: "bar",
      },
    );

    const defaultInstancesScript = findInstancesScript(defaultState);
    expect(defaultInstancesScript).toBeString();

    const { username: defaultUsername, password: defaultPassword } =
      formEntryValuesRe.exec(defaultInstancesScript)?.groups ?? {};

    expect(defaultUsername).toBe("Administrator");
    expect(defaultPassword).toBe("coderRDP!");

    // Test that custom usernames/passwords are also forwarded correctly
    const userDefinedUsername = "crouton";
    const userDefinedPassword = "VeryVeryVeryVeryVerySecurePassword97!";
    const customizedState = await runTerraformApply<TestVariables>(
      import.meta.dir,
      {
        agent_id: "foo",
        resource_id: "bar",
        admin_username: userDefinedUsername,
        admin_password: userDefinedPassword,
      },
    );

    const customInstancesScript = findInstancesScript(customizedState);
    expect(customInstancesScript).toBeString();

    const { username: customUsername, password: customPassword } =
      formEntryValuesRe.exec(customInstancesScript)?.groups ?? {};

    expect(customUsername).toBe(userDefinedUsername);
    expect(customPassword).toBe(userDefinedPassword);
  });
});
