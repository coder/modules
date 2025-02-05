import { describe, expect, it } from "bun:test";
import {
  executeScriptInContainer,
  runTerraformApply,
  runTerraformInit,
  testRequiredVariables,
} from "../test";

describe("filebrowser", async () => {
  await runTerraformInit(import.meta.dir);

  testRequiredVariables(import.meta.dir, {
    agent_id: "foo",
  });

  it("fails with wrong database_path", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      database_path: "nofb",
    }).catch((e) => {
      if (!e.message.startsWith("\nError: Invalid value for variable")) {
        throw e;
      }
    });
  });

  it("runs with default", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
    });
    const output = await executeScriptInContainer(state, "alpine");
    expect(output.exitCode).toBe(0);
    expect(output.stdout).toEqual([
      "\u001b[0;1mInstalling filebrowser ",
      "",
      "🥳 Installation complete! ",
      "",
      "👷 Starting filebrowser in background... ",
      "",
      "📂 Serving /root at http://localhost:13339 ",
      "",
      "Running 'filebrowser --noauth --root /root --port 13339 --baseurl ' ",
      "",
      "📝 Logs at /tmp/filebrowser.log",
    ]);
  });

  it("runs with database_path var", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      database_path: ".config/filebrowser.db",
    });
    const output = await executeScriptInContainer(state, "alpine");
    expect(output.exitCode).toBe(0);
    expect(output.stdout).toEqual([
      "\u001b[0;1mInstalling filebrowser ",
      "",
      "🥳 Installation complete! ",
      "",
      "👷 Starting filebrowser in background... ",
      "",
      "📂 Serving /root at http://localhost:13339 ",
      "",
      "Running 'filebrowser --noauth --root /root --port 13339 -d .config/filebrowser.db --baseurl ' ",
      "",
      "📝 Logs at /tmp/filebrowser.log",
    ]);
  });

  it("runs with folder var", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      folder: "/home/coder/project",
    });
    const output = await executeScriptInContainer(state, "alpine");
    expect(output.exitCode).toBe(0);
    expect(output.stdout).toEqual([
      "\u001b[0;1mInstalling filebrowser ",
      "",
      "🥳 Installation complete! ",
      "",
      "👷 Starting filebrowser in background... ",
      "",
      "📂 Serving /home/coder/project at http://localhost:13339 ",
      "",
      "Running 'filebrowser --noauth --root /home/coder/project --port 13339 --baseurl ' ",
      "",
      "📝 Logs at /tmp/filebrowser.log",
    ]);
  });

  it("runs with subdomain=false", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      agent_name: "main",
      subdomain: false,
    });
    const output = await executeScriptInContainer(state, "alpine");
    expect(output.exitCode).toBe(0);
    expect(output.stdout).toEqual([
      "\u001B[0;1mInstalling filebrowser ",
      "",
      "🥳 Installation complete! ",
      "",
      "👷 Starting filebrowser in background... ",
      "",
      "📂 Serving /root at http://localhost:13339 ",
      "",
      "Running 'filebrowser --noauth --root /root --port 13339 --baseurl /@default/default.main/apps/filebrowser' ",
      "",
      "📝 Logs at /tmp/filebrowser.log",
    ]);
  });
});
