import { describe, expect, it } from "bun:test";
import {
  runTerraformApply,
  runTerraformInit,
  testRequiredVariables,
} from "../test";

describe("dotfiles", async () => {
  await runTerraformInit(import.meta.dir);

  testRequiredVariables(import.meta.dir, {
    agent_id: "foo",
  });

  it("default output", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
    });
    expect(state.outputs.dotfiles_uri.value).toBe("");
  });
  
  it("set a default dotfiles_uri", async () => {
    const default_dotfiles_uri = "foo";
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      default_dotfiles_uri,
    });
    expect(state.outputs.dotfiles_uri.value).toBe(default_dotfiles_uri);
  });
});
