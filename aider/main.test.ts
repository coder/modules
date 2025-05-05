import { describe, expect, it } from "bun:test";
import {
  executeScriptInContainer,
  runTerraformApply,
  runTerraformInit,
  testRequiredVariables,
  writeCoder,
} from "../test";

describe("aider", async () => {
  await runTerraformInit(import.meta.dir);

  testRequiredVariables(import.meta.dir, {
    agent_id: "foo",
  });

  it("installs aider with default settings", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
    });

    // Execute the script with mock setup first
    const output = await executeScriptInContainer(
      state,
      "alpine",
      "sh",
      "mkdir -p /home/coder/bin && echo '#!/bin/sh\necho \"Aider mock started\"' > /home/coder/bin/aider && chmod +x /home/coder/bin/aider && " +
        "mkdir -p /usr/bin && echo '#!/bin/sh\necho \"screen mock $@\"' > /usr/bin/screen && chmod +x /usr/bin/screen",
    );

    // Verify expected outputs
    expect(output.exitCode).toBe(0);
    expect(output.stdout).toContain("Setting up Aider AI pair programming...");
    expect(output.stdout).toContain(
      "Screen session 'aider' started. Access it by clicking the Aider button.",
    );
  });

  it("uses tmux when specified", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      use_tmux: true,
      use_screen: false,
    });

    // Execute the script with mock setup first
    const output = await executeScriptInContainer(
      state,
      "alpine",
      "sh",
      "mkdir -p /home/coder/bin && echo '#!/bin/sh\necho \"Aider mock started\"' > /home/coder/bin/aider && chmod +x /home/coder/bin/aider && " +
        "mkdir -p /usr/bin && echo '#!/bin/sh\necho \"tmux mock $@\"' > /usr/bin/tmux && chmod +x /usr/bin/tmux",
    );

    // Verify expected outputs
    expect(output.exitCode).toBe(0);
    expect(output.stdout).toContain(
      "Tmux session 'aider' started. Access it by clicking the Aider button.",
    );
  });

  it("configures task reporting when enabled", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      experiment_report_tasks: true,
    });

    // Set up mocks including coder command
    const mockSetup =
      "mkdir -p /usr/bin && echo '#!/bin/sh\necho \"coder mock $@\"' > /usr/bin/coder && chmod +x /usr/bin/coder && " +
      "mkdir -p /home/coder/bin && echo '#!/bin/sh\necho \"Aider mock started\"' > /home/coder/bin/aider && chmod +x /home/coder/bin/aider && " +
      "mkdir -p /usr/bin && echo '#!/bin/sh\necho \"screen mock $@\"' > /usr/bin/screen && chmod +x /usr/bin/screen";

    // Execute the script with mock setup
    const output = await executeScriptInContainer(
      state,
      "alpine",
      "sh",
      mockSetup,
    );

    // Verify expected outputs
    expect(output.exitCode).toBe(0);
    expect(output.stdout).toContain(
      "Configuring Aider to report tasks via Coder MCP...",
    );
  });

  it("executes pre and post install scripts", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      experiment_pre_install_script: "echo 'Pre-install script executed'",
      experiment_post_install_script: "echo 'Post-install script executed'",
    });

    // Execute the script with basic mocks
    const output = await executeScriptInContainer(
      state,
      "alpine",
      "sh",
      "mkdir -p /home/coder/bin && echo '#!/bin/sh\necho \"Aider mock started\"' > /home/coder/bin/aider && chmod +x /home/coder/bin/aider && " +
        "mkdir -p /usr/bin && echo '#!/bin/sh\necho \"screen mock $@\"' > /usr/bin/screen && chmod +x /usr/bin/screen",
    );

    // Verify expected outputs
    expect(output.exitCode).toBe(0);
    expect(output.stdout).toContain("Running pre-install script...");
    expect(output.stdout).toContain("Running post-install script...");
  });
});
