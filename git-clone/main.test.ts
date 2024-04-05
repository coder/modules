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

  it("repo_dir should match repo name for https", async () => {
    const url = "https://github.com/coder/coder.git";
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      base_dir: "/tmp",
      url,
    });
    expect(state.outputs.repo_dir.value).toEqual("/tmp/coder");
    expect(state.outputs.clone_url.value).toEqual(url);
    expect(state.outputs.web_url.value).toEqual(url);
    expect(state.outputs.branch_name.value).toEqual("");
  });

  it("repo_dir should match repo name for https without .git", async () => {
    const url = "https://github.com/coder/coder";
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      base_dir: "/tmp",
      url,
    });
    expect(state.outputs.repo_dir.value).toEqual("/tmp/coder");
    expect(state.outputs.clone_url.value).toEqual(url);
    expect(state.outputs.web_url.value).toEqual(url);
    expect(state.outputs.branch_name.value).toEqual("");
  });

  it("repo_dir should match repo name for ssh", async () => {
    const url = "git@github.com:coder/coder.git";
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      base_dir: "/tmp",
      url,
    });
    expect(state.outputs.repo_dir.value).toEqual("/tmp/coder");
    expect(state.outputs.clone_url.value).toEqual(url);
    expect(state.outputs.web_url.value).toEqual(
      "https://github.com/coder/coder.git",
    );
    expect(state.outputs.branch_name.value).toEqual("");
  });

  it("branch_name should not include query string", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      base_dir: "/tmp",
      url: "https://gitlab.com/mike.brew/repo-tests.log/-/tree/feat/branch?ref_type=heads",
    });
    expect(state.outputs.repo_dir.value).toEqual("/tmp/repo-tests.log");
    const https_url = "https://gitlab.com/mike.brew/repo-tests.log";
    expect(state.outputs.clone_url.value).toEqual(https_url);
    expect(state.outputs.web_url.value).toEqual(https_url);
    expect(state.outputs.branch_name.value).toEqual("feat/branch");
  });

  it("branch_name should not include fragments", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      base_dir: "/tmp",
      url: "https://gitlab.com/mike.brew/repo-tests.log/-/tree/feat/branch#name",
    });
    expect(state.outputs.repo_dir.value).toEqual("/tmp/repo-tests.log");
    const https_url = "https://gitlab.com/mike.brew/repo-tests.log";
    expect(state.outputs.clone_url.value).toEqual(https_url);
    expect(state.outputs.web_url.value).toEqual(https_url);
    expect(state.outputs.branch_name.value).toEqual("feat/branch");
  });

  it("repo_dir should match repo name with gitlab tree url", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      base_dir: "/tmp",
      url: "https://gitlab.com/mike.brew/repo-tests.log/-/tree/feat/branch",
    });
    expect(state.outputs.repo_dir.value).toEqual("/tmp/repo-tests.log");
    const https_url = "https://gitlab.com/mike.brew/repo-tests.log";
    expect(state.outputs.clone_url.value).toEqual(https_url);
    expect(state.outputs.web_url.value).toEqual(https_url);
    expect(state.outputs.branch_name.value).toEqual("feat/branch");
  });

  it("repo_dir should match repo name with github tree url", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      base_dir: "/tmp",
      url: "https://github.com/michaelbrewer/repo-tests.log/tree/feat/branch",
    });
    expect(state.outputs.repo_dir.value).toEqual("/tmp/repo-tests.log");
    const https_url = "https://github.com/michaelbrewer/repo-tests.log";
    expect(state.outputs.clone_url.value).toEqual(https_url);
    expect(state.outputs.web_url.value).toEqual(https_url);
    expect(state.outputs.branch_name.value).toEqual("feat/branch");
  });

  it("runs with github clone with switch to feat/branch", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      url: "https://github.com/michaelbrewer/repo-tests.log/tree/feat/branch",
    });
    const output = await executeScriptInContainer(state, "alpine/git");
    expect(output.exitCode).toBe(0);
    expect(output.stdout).toEqual([
      "Creating directory ~/repo-tests.log...",
      "Cloning https://github.com/michaelbrewer/repo-tests.log to ~/repo-tests.log on branch feat/branch...",
    ]);
  });

  it("runs with gitlab clone with switch to feat/branch", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      url: "https://gitlab.com/mike.brew/repo-tests.log/-/tree/feat/branch",
    });
    const output = await executeScriptInContainer(state, "alpine/git");
    expect(output.exitCode).toBe(0);
    expect(output.stdout).toEqual([
      "Creating directory ~/repo-tests.log...",
      "Cloning https://gitlab.com/mike.brew/repo-tests.log to ~/repo-tests.log on branch feat/branch...",
    ]);
  });
});
