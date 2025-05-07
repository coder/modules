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

  // Run the script with the environment variables from extraCommands
  // Modifying to preserve environment variables
  const resp = await execContainer(id, [
    "bash",
    "-c",
    `
    # Source any environment variables that might have been set
    if [ -f /tmp/env_vars.sh ]; then
      source /tmp/env_vars.sh
    fi
    
    # Run the script
    ${instance.script}
  `,
  ]);
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

    // Instead of running the script, just verify the script content
    // to ensure the tmux parameter is being properly applied
    const instance = findResourceInstance(state, "coder_script");

    // Check for the correct tmux condition with the interpolated value
    expect(instance.script.includes('if [ "true" = "true" ]')).toBe(true);

    // Also check for a unique string only present when tmux is used in the script
    expect(instance.script.includes("tmux new-session -d -s")).toBe(true);
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

  it("passes aider cmd with correct flags when prompt is provided", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
    });

    // Define a test prompt
    const testPrompt = "Add a hello world function";

    // Set up the environment variable for the task prompt
    const output = await executeScriptInContainerWithBash(
      state,
      "alpine",
      `echo 'export CODER_MCP_AIDER_TASK_PROMPT="${testPrompt}"' > /tmp/env_vars.sh`,
    );

    // Debug: print all output lines
    console.log("DEBUG OUTPUT LINES:");
    output.stdout.forEach((line) => console.log(`> ${line}`));

    // Check if script contains the proper command construction with all required flags
    const instance = findResourceInstance(state, "coder_script");

    // Verify all required flags are present in the aider command
    expect(
      instance.script.includes(
        "aider --architect --yes-always --read CONVENTIONS.md --message",
      ),
    ).toBe(true);

    // Verify the expected message format is correct
    expect(
      instance.script.includes(
        '--message "Report each step to Coder. Your task: $CODER_MCP_AIDER_TASK_PROMPT"',
      ),
    ).toBe(true);

    // Verify the script creates a flag file to prevent duplicate execution
    expect(instance.script.includes('touch "$HOME/.aider_task_executed"')).toBe(
      true,
    );

    // Verify logging to the aider log file
    expect(instance.script.includes('| tee -a "$HOME/.aider.log"')).toBe(true);

    // Verify the output shows the right message for screen session
    expect(
      output.stdout.some((line) =>
        line.includes("Running Aider with message in screen session"),
      ),
    ).toBe(true);

    // Verify the appropriate starting message is shown
    expect(output.stdout).toContain(
      "Aider task started in screen session 'aider'. Check the logs for progress.",
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
