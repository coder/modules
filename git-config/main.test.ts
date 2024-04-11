import { describe, expect, it } from "bun:test";
import {
  runTerraformApply,
  runTerraformInit,
  testRequiredVariables,
} from "../test";

describe("git-config", async () => {
  await runTerraformInit(import.meta.dir);

  testRequiredVariables(import.meta.dir, {
    agent_id: "foo",
  });

  it("can run apply allow_username_change and allow_email_change disabled", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      allow_username_change: "false",
      allow_email_change: "false",
    });

    const resources = state.resources;
    expect(resources).toHaveLength(3);
    expect(resources).toMatchObject([
      { type: "coder_workspace", name: "me" },
      { type: "coder_env", name: "git_author_name" },
      { type: "coder_env", name: "git_commmiter_name" },
    ]);
  });

  it("can run apply allow_email_change enabled", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      allow_email_change: "true",
    });

    const resources = state.resources;
    expect(resources).toHaveLength(5);
    expect(resources).toMatchObject([
      { type: "coder_parameter", name: "user_email" },
      { type: "coder_parameter", name: "username" },
      { type: "coder_workspace", name: "me" },
      { type: "coder_env", name: "git_author_name" },
      { type: "coder_env", name: "git_commmiter_name" },
    ]);
  });

  it("can run apply allow_email_change enabled", async () => {
    const state = await runTerraformApply(
      import.meta.dir,
      {
        agent_id: "foo",
        allow_username_change: "false",
        allow_email_change: "false",
      },
      { CODER_WORKSPACE_OWNER_EMAIL: "foo@emai.com" },
    );

    const resources = state.resources;
    expect(resources).toHaveLength(5);
    expect(resources).toMatchObject([
      { type: "coder_workspace", name: "me" },
      { type: "coder_env", name: "git_author_email" },
      { type: "coder_env", name: "git_author_name" },
      { type: "coder_env", name: "git_commmiter_email" },
      { type: "coder_env", name: "git_commmiter_name" },
    ]);
  });
});
