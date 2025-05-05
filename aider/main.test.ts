import { describe, expect, it } from "bun:test";
import {
  execContainer,
  executeScriptInContainer,
  findResourceInstance,
  runContainer,
  runTerraformApply,
  runTerraformInit,
  testRequiredVariables,
  type TerraformState,
} from "../test";

/**
 * Helper function that executes the script in a container after setting up
 * the necessary environment for testing.
 */
const executeScriptInContainerWithMockEnv = async (
  state: TerraformState,
  image = "alpine",
  shell = "bash",
  extraSetup?: string
): Promise<{
  exitCode: number;
  stdout: string[];
  stderr: string[];
}> => {
  const instance = findResourceInstance(state, "coder_script");
  const id = await runContainer(image);

  // Set up the container with necessary tools and mocks
  const setupCommands = `
    # Install bash and other necessary packages
    apk add --no-cache bash
    
    # Set up environment
    export HOME=/home/coder
    
    # Create necessary directories
    mkdir -p /home/coder/bin
    mkdir -p /home/coder/.config
    mkdir -p /usr/bin
    
    # Mock commands we need for the aider script
    echo '#!/bin/bash
    echo "Linux"' > /usr/bin/uname
    chmod +x /usr/bin/uname
    
    # Mock command for checking if command exists
    echo '#!/bin/bash
    true' > /usr/bin/command
    chmod +x /usr/bin/command
    
    # Mock sudo to just run the command without sudo
    echo '#!/bin/bash
    shift
    "$@"' > /usr/bin/sudo
    chmod +x /usr/bin/sudo
    
    # Set up apt-get mock
    echo '#!/bin/bash
    echo "apt-get $@"' > /usr/bin/apt-get
    chmod +x /usr/bin/apt-get
    
    # Set up dnf mock
    echo '#!/bin/bash
    echo "dnf $@"' > /usr/bin/dnf
    chmod +x /usr/bin/dnf
    
    # Set up aider mock
    echo '#!/bin/bash
    echo "Aider mock started"' > /home/coder/bin/aider
    chmod +x /home/coder/bin/aider
    export PATH=/home/coder/bin:$PATH
    
    # Set up screen mock
    echo '#!/bin/bash
    echo "screen mock $@"' > /usr/bin/screen
    chmod +x /usr/bin/screen
    
    # Set up curl mock
    echo '#!/bin/bash
    echo "curl mock $@"' > /usr/bin/curl
    chmod +x /usr/bin/curl
    
    # Set up base64 mock
    echo '#!/bin/bash
    if [ "$1" = "-d" ]; then 
      cat
    else 
      echo "base64 $@"
    fi' > /usr/bin/base64
    chmod +x /usr/bin/base64
    
    # Create empty aider log file
    touch /home/coder/.aider.log
    
    # Run any extra setup commands if provided
    ${extraSetup || ""}
  `;

  await execContainer(id, ["sh", "-c", setupCommands]);
  
  // Now run the actual script
  const resp = await execContainer(id, [shell, "-c", instance.script]);
  
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

    const output = await executeScriptInContainerWithMockEnv(state);

    // Verify expected outputs
    expect(output.exitCode).toBe(0);
    expect(output.stdout).toContain("Setting up Aider AI pair programming...");
    expect(output.stdout).toContain(
      "Screen session 'aider' started. Access it by clicking the Aider button."
    );
  });

  it("uses tmux when specified", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      use_tmux: true,
      use_screen: false,
    });

    const output = await executeScriptInContainerWithMockEnv(
      state,
      "alpine",
      "bash",
      `
      # Set up tmux mock instead of screen
      echo '#!/bin/bash
      echo "tmux mock $@"' > /usr/bin/tmux
      chmod +x /usr/bin/tmux
      `
    );

    // Verify expected outputs
    expect(output.exitCode).toBe(0);
    expect(output.stdout).toContain(
      "Tmux session 'aider' started. Access it by clicking the Aider button."
    );
  });

  it("configures task reporting when enabled", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      experiment_report_tasks: true,
    });

    const output = await executeScriptInContainerWithMockEnv(
      state,
      "alpine",
      "bash",
      `
      # Set up coder mock
      echo '#!/bin/bash
      echo "coder mock $@"' > /usr/bin/coder
      chmod +x /usr/bin/coder
      `
    );

    // Verify expected outputs
    expect(output.exitCode).toBe(0);
    expect(output.stdout).toContain(
      "Configuring Aider to report tasks via Coder MCP..."
    );
  });

  it("executes pre and post install scripts", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      experiment_pre_install_script: "echo 'Pre-install script executed'",
      experiment_post_install_script: "echo 'Post-install script executed'",
    });

    const output = await executeScriptInContainerWithMockEnv(state);

    // Verify expected outputs
    expect(output.exitCode).toBe(0);
    expect(output.stdout).toContain("Running pre-install script...");
    expect(output.stdout).toContain("Running post-install script...");
  });
});
