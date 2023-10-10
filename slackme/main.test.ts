import { describe, expect, it } from "bun:test";
import {
  createJSONResponse,
  execContainer,
  executeScriptInContainer,
  findResourceInstance,
  runContainer,
  runTerraformApply,
  runTerraformInit,
  testRequiredVariables,
} from "../test";
import { serve } from "bun";

describe("slackme", async () => {
  await runTerraformInit(import.meta.dir);

  testRequiredVariables(import.meta.dir, {
    agent_id: "foo",
    auth_provider_id: "foo",
  });

  const setupContainer = async (image = "alpine") => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      auth_provider_id: "foo",
    });
    const instance = findResourceInstance(state, "coder_script");
    const id = await runContainer(image);
    return { id, instance };
  };

  const writeCoder = async (id: string, script: string) => {
    const exec = await execContainer(id, [
      "sh",
      "-c",
      `echo '${script}' > /usr/bin/coder && chmod +x /usr/bin/coder`,
    ]);
    expect(exec.exitCode).toBe(0);
  };

  it("writes to path as executable", async () => {
    const { instance, id } = await setupContainer();
    await writeCoder(id, "exit 0");
    let exec = await execContainer(id, ["sh", "-c", instance.script]);
    expect(exec.exitCode).toBe(0);
    exec = await execContainer(id, ["sh", "-c", "which slackme"]);
    expect(exec.exitCode).toBe(0);
    expect(exec.stdout.trim()).toEqual("/usr/bin/slackme");
  });

  it("prints usage with no command", async () => {
    const { instance, id } = await setupContainer();
    await writeCoder(id, "echo 👋");
    let exec = await execContainer(id, ["sh", "-c", instance.script]);
    expect(exec.exitCode).toBe(0);
    exec = await execContainer(id, ["sh", "-c", "slackme"]);
    expect(exec.stdout.trim()).toStartWith(
      "slackme — Send a Slack notification when a command finishes",
    );
  });

  it("displays url when not authenticated", async () => {
    const { instance, id } = await setupContainer();
    await writeCoder(id, "echo 'some-url' && exit 1");
    let exec = await execContainer(id, ["sh", "-c", instance.script]);
    expect(exec.exitCode).toBe(0);
    exec = await execContainer(id, ["sh", "-c", "slackme echo test"]);
    expect(exec.stdout.trim()).toEndWith("some-url");
  });

  it("curls url when authenticated", async () => {
    let url: URL;
    const fakeSlackHost = serve({
      fetch: (req) => {
        url = new URL(req.url);
        if (url.pathname === "/api/chat.postMessage")
          return createJSONResponse({
            ok: true,
          });
        return createJSONResponse({}, 404);
      },
      port: 0,
    });

    const { instance, id } = await setupContainer("alpine/curl");
    await writeCoder(id, "echo 'token'");
    let exec = await execContainer(id, ["sh", "-c", instance.script]);
    expect(exec.exitCode).toBe(0);
    exec = await execContainer(id, [
      "sh",
      "-c",
      `SLACK_URL="http://${fakeSlackHost.hostname}:${fakeSlackHost.port}" slackme echo test`,
    ]);
    expect(exec.stdout.trim()).toEndWith("test");
    expect(url.pathname).toEqual("/api/chat.postMessage");
    expect(url.searchParams.get("channel")).toEqual("token");
  });
});
