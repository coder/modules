import { describe, expect, it } from "bun:test";
import {
  execContainer,
  findResourceInstance,
  runContainer,
  runTerraformApply,
  runTerraformInit,
  testRequiredVariables,
  type TerraformState,
} from "../test";

// Executes the coder script after installing bash (required for the script)
const executeScriptInContainerWithBash = async (
  state: TerraformState,
  image = "alpine",
  extraCommands = "",
): Promise<{
  exitCode: number;
  stdout: string[];
  stderr: string[];
}> => {
  const instance = findResourceInstance(state, "coder_script");
  const id = await runContainer(image);

  // Install bash and set up the minimal environment needed
  await execContainer(id, [
    "sh",
    "-c",
    `
    apk add --no-cache bash
    mkdir -p /home/coder/bin
    touch /home/coder/.aider.log
    ${extraCommands}
  `,
  ]);

  // Run the script
  const resp = await execContainer(id, ["bash", "-c", instance.script]);
  const stdout = resp.stdout.trim().split("\n");
  const stderr = resp.stderr.trim().split("\n");
  return {
    exitCode: resp.exitCode,
    stdout,
    stderr,
  };
};

describe("aider", async () => {
  await runTerraformInit(import.meta.dir);

  testRequiredVariables(import.meta.dir, {
    agent_id: "foo",
  });

  it("installs aider with default settings", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
    });

    // Install bash and run the script
    const output = await executeScriptInContainerWithBash(state);

    // Verify that the script at least attempted to set up Aider
    expect(output.stdout).toContain("Setting up Aider AI pair programming...");
  });

  it("uses tmux when specified", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      use_tmux: true,
      use_screen: false,
    });

    // Create apt-get that will be detected in the script
    const output = await executeScriptInContainerWithBash(
      state,
      "alpine",
      `
      # Create apt-get in PATH so the script's command_exists function will find it
      mkdir -p /usr/bin
      echo '#!/bin/sh
      if [ "$1" = "install" ] && [[ "$*" == *tmux* ]]; then
        echo "Installing tmux for persistent sessions..."
      else
        echo "apt-get $@"
      fi' > /usr/bin/apt-get
      chmod +x /usr/bin/apt-get
      
      # Create a minimal sudo command
      echo '#!/bin/sh
      shift
      $@' > /usr/bin/sudo
      chmod +x /usr/bin/sudo
      `,
    );

    // Verify that the script attempts to install tmux
    expect(output.stdout).toContain(
      "Installing tmux for persistent sessions...",
    );
  });

  it("configures task reporting when enabled", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      experiment_report_tasks: true,
    });

    // Install bash and run the script
    const output = await executeScriptInContainerWithBash(state);

    // Verify task reporting is mentioned
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

    // Install bash and run the script
    const output = await executeScriptInContainerWithBash(state);

    // Verify pre/post script messages
    expect(output.stdout).toContain("Running pre-install script...");
    expect(output.stdout).toContain("Running post-install script...");
  });
});
