import { describe, expect, it } from "bun:test";
import {
  executeScriptInContainer,
  runTerraformApply,
  runTerraformInit,
  testRequiredVariables,
} from "../test";

describe("vscode-desktop", async () => {
  await runTerraformInit(import.meta.dir);

  testRequiredVariables(import.meta.dir, {
    agent_id: "foo",
  });

  it("default output", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
    });
    expect(state.outputs.vscode_url.value).toBe(
      "vscode://coder.coder-remote/open?owner=default&workspace=default&token=$SESSION_TOKEN",
    );

    const resources = state.resources;
    expect(resources[1].instances[0].attributes.order).toBeNull();
  });

  it("expect order to be set", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      order: "22",
    });

    const resources = state.resources;
    expect(resources[1].instances[0].attributes.order).toBe(22);
  });
});
