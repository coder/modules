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

    const output = await executeScriptInContainerWithBash(state);

    expect(output.stdout).toContain("Setting up Aider AI pair programming...");
  });

  it("configures task reporting when enabled", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      experiment_report_tasks: true,
    });

    const output = await executeScriptInContainerWithBash(state);

    expect(output.stdout).toContain(
      "Configuring Aider to report tasks via Coder MCP...",
    );
  });

  it("passes aider cmd with correct flags when prompt is provided", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
    });

    const testPrompt = "Add a hello world function";

    const output = await executeScriptInContainerWithBash(
      state,
      "alpine",
      `echo 'export CODER_MCP_AIDER_TASK_PROMPT="${testPrompt}"' > /tmp/env_vars.sh`,
    );

    const instance = findResourceInstance(state, "coder_script");

    expect(
      instance.script.includes(
        "aider --architect --yes-always --read CONVENTIONS.md --message",
      ),
    ).toBe(true);

    expect(
      instance.script.includes(
        '--message \\"Report each step to Coder. Your task: $CODER_MCP_AIDER_TASK_PROMPT\\"',
      ),
    ).toBe(true);

    expect(
      instance.script.includes('export CODER_MCP_APP_STATUS_SLUG=\\"aider\\"'),
    ).toBe(true);

    expect(
      output.stdout.some((line) =>
        line.includes("Running Aider with message in screen session"),
      ),
    ).toBe(true);

    expect(
      output.stdout.some((line) =>
        line.includes("Creating ~/.screenrc and adding multiuser settings"),
      ),
    ).toBe(true);
  });

  it("executes pre and post install scripts", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      experiment_pre_install_script: "echo 'Pre-install script executed'",
      experiment_post_install_script: "echo 'Post-install script executed'",
    });

    const output = await executeScriptInContainerWithBash(state);

    expect(output.stdout).toContain("Running pre-install script...");
    expect(output.stdout).toContain("Running post-install script...");
  });
});
