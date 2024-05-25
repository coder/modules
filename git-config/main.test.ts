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
    expect(resources).toMatchObject([
      { type: "coder_workspace", name: "me" },
      { type: "coder_env", name: "git_author_name" },
      { type: "coder_env", name: "git_commmiter_name" },
    ]);
    expect(resources).toHaveLength(3);
  });

  it("can run apply allow_email_change enabled", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      allow_email_change: "true",
    });

    const resources = state.resources;
    expect(resources).toMatchObject([
      { type: "coder_parameter", name: "user_email" },
      { type: "coder_parameter", name: "username" },
      { type: "coder_workspace", name: "me" },
      { type: "coder_env", name: "git_author_name" },
      { type: "coder_env", name: "git_commmiter_name" },
    ]);
    expect(resources).toHaveLength(5);
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

  it("set custom order for coder_parameter for both fields", async () => {
    const order = 20;
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      allow_username_change: "true",
      allow_email_change: "true",
      coder_parameter_order: order.toString(),
    });
    expect(state.resources).toHaveLength(5);
    // user_email order is the same as the order
    expect(state.resources[0].instances[0].attributes.order).toBe(order);
    // username order is incremented by 1
    // @ts-ignore: Object is possibly 'null'.
    expect(state.resources[1].instances[0]?.attributes.order).toBe(order + 1);
  });

  it("set custom order for coder_parameter for just username", async () => {
    const order = 30;
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      allow_email_change: "false",
      allow_username_change: "true",
      coder_parameter_order: order.toString(),
    });
    expect(state.resources).toHaveLength(4);
    // user_email was not created
    // username order is incremented by 1
    expect(state.resources[0].instances[0].attributes.order).toBe(order + 1);
  });
});
