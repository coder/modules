import { describe, expect, it } from "bun:test";
import {
  executeScriptInContainer,
  runTerraformApply,
  runTerraformInit,
  testRequiredVariables,
} from "../test";

describe("git-clone", async () => {
  await runTerraformInit(import.meta.dir);

  testRequiredVariables(import.meta.dir, {
    agent_id: "foo",
    url: "foo",
  });

  it("repo_dir should match repo name for https", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      base_dir: "/tmp",
      url: "https://github.com/coder/coder.git",
    });
    expect(state.outputs.repo_dir.value).toEqual("/tmp/coder");
    expect(state.outputs.clone_url.value).toEqual(
      "https://github.com/coder/coder.git",
    );
    expect(state.outputs.branch_name.value).toEqual("");
  });

  it("repo_dir should match repo name for https without .git", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      base_dir: "/tmp",
      url: "https://github.com/coder/coder",
    });
    expect(state.outputs.repo_dir.value).toEqual("/tmp/coder");
    expect(state.outputs.clone_url.value).toEqual(
      "https://github.com/coder/coder",
    );
    expect(state.outputs.branch_name.value).toEqual("");
  });

  it("repo_dir should match repo name for ssh", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      base_dir: "/tmp",
      url: "git@github.com:coder/coder.git",
    });
    expect(state.outputs.repo_dir.value).toEqual("/tmp/coder");
    expect(state.outputs.clone_url.value).toEqual(
      "git@github.com:coder/coder.git",
    );
    expect(state.outputs.branch_name.value).toEqual("");
  });

  it("repo_dir should match repo name with gitlab tree url", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      base_dir: "/tmp",
      url: "https://gitlab.com/mike.brew/repo-tests.log/-/tree/feat/branch",
    });
    expect(state.outputs.repo_dir.value).toEqual("/tmp/repo-tests.log");
    expect(state.outputs.clone_url.value).toEqual(
      "https://gitlab.com/mike.brew/repo-tests.log",
    );
    expect(state.outputs.branch_name.value).toEqual("feat/branch");
  });

  it("repo_dir should match repo name with github tree url", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      base_dir: "/tmp",
      url: "https://github.com/michaelbrewer/repo-tests.log/tree/feat/branch",
    });
    expect(state.outputs.repo_dir.value).toEqual("/tmp/repo-tests.log");
    expect(state.outputs.clone_url.value).toEqual(
      "https://github.com/michaelbrewer/repo-tests.log",
    );
    expect(state.outputs.branch_name.value).toEqual("feat/branch");
  });

  it("fails without git", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      url: "some-url",
    });
    const output = await executeScriptInContainer(state, "alpine");
    expect(output.exitCode).toBe(1);
    expect(output.stdout).toEqual(["Git is not installed!"]);
  });

  it("runs with git", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      url: "fake-url",
    });
    const output = await executeScriptInContainer(state, "alpine/git");
    expect(output.exitCode).toBe(128);
    expect(output.stdout).toEqual([
      "Creating directory ~/fake-url...",
      "Cloning fake-url to ~/fake-url...",
    ]);
  });
});
