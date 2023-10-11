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
    const output = await executeScriptInContainer(state, "alpine");
    expect(output.exitCode).toBe(1);
    expect(output.stdout).toEqual([
      "\u001b[0;1mInstalling vscode-cli!",
      "Failed to install vscode-cli:", // TODO: manually test error log
    ]);
  });

  it("runs with curl", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      accept_license: "true",
    });
    const output = await executeScriptInContainer(state, "alpine/curl");
    expect(output.exitCode).toBe(0);
    expect(output.stdout).toEqual([
      "\u001b[0;1mInstalling vscode-cli!",
      "🥳 vscode-cli has been installed.",
      "",
      "👷 Running /tmp/vscode-cli/bin/code serve-web --port 13338 --without-connection-token --accept-server-license-terms in the background...",
      "Check logs at /tmp/vscode-web.log!",
    ]);
  });
});
