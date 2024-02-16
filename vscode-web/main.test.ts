import { describe, expect, it } from "bun:test";
import {
  executeScriptInContainer,
  runTerraformApply,
  runTerraformInit,
} from "../test";

describe("vscode-web", async () => {
  await runTerraformInit(import.meta.dir);

  // replaces testRequiredVariables due to license variable
  // may add a testRequiredVariablesWithLicense function later
  it("missing agent_id", async () => {
    try {
      await runTerraformApply(import.meta.dir, {
        accept_license: "true",
      });
    } catch (ex) {
      expect(ex.message).toContain('input variable "agent_id" is not set');
    }
  });

  it("invalid license_agreement", async () => {
    try {
      await runTerraformApply(import.meta.dir, {
        agent_id: "foo",
      });
    } catch (ex) {
      expect(ex.message).toContain(
        "You must accept the VS Code license agreement by setting accept_license=true",
      );
    }
  });

  it("fails without curl", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      accept_license: "true",
    });
    const output = await executeScriptInContainer(state, "alpine", "apk add gcompat libgcc libstdc++");
    expect(output.exitCode).toBe(1);
    expect(output.stdout).toEqual([
      "\u001b[0;1mInstalling Microsoft Visual Studio Code Server!",
      "Failed to install Microsoft Visual Studio Code Server:", // TODO: manually test error log
    ]);
  }, 15000); // 15 seconds timeout

  it("runs with curl", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      accept_license: "true",
    });
    const output = await executeScriptInContainer(state, "alpine/curl", "apk add gcompat libgcc libstdc++");
    expect(output.exitCode).toBe(0);
    expect(output.stdout).toEqual([
      "\u001b[0;1mInstalling Microsoft Visual Studio Code Server!",
      "🥳 Microsoft Visual Studio Code Server has been installed.",
      "",
      "👷 Running /tmp/vscode-web/bin/code-server serve-local --port 13338 --accept-server-license-terms serve-local --without-connection-token --telemetry-level error in the background...",
      "Check logs at /tmp/vscode-web.log!",
    ]);
  }, 15000); // 15 seconds timeout
});
