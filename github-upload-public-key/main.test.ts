import { describe, expect, it } from "bun:test";
import {
  createJSONResponse,
  execContainer,
  findResourceInstance,
  runContainer,
  runTerraformApply,
  runTerraformInit,
  testRequiredVariables,
  writeCoder,
} from "../test";
import { Server, serve } from "bun";

describe("github-upload-public-key", async () => {
  await runTerraformInit(import.meta.dir);

  testRequiredVariables(import.meta.dir, {
    agent_id: "foo",
  });

  it("creates new key if one does not exist", async () => {
    const { instance, id, server } = await setupContainer();
    await writeCoder(id, "echo foo");
    let exec = await execContainer(id, [
      "env",
      "CODER_ACCESS_URL=" + server.url.toString().slice(0, -1),
      "GITHUB_API_URL=" + server.url.toString().slice(0, -1),
      "CODER_OWNER_SESSION_TOKEN=foo",
      "CODER_EXTERNAL_AUTH_ID=github",
      "bash",
      "-c",
      instance.script,
    ]);
    expect(exec.stdout).toContain(
      "Your Coder public key has been added to GitHub!",
    );
    expect(exec.exitCode).toBe(0);
    // we need to increase timeout to pull the container
  }, 15000);

  it("does nothing if one already exists", async () => {
    const { instance, id, server } = await setupContainer();
    // use keyword to make server return a existing key
    await writeCoder(id, "echo findkey");
    let exec = await execContainer(id, [
      "env",
      "CODER_ACCESS_URL=" + server.url.toString().slice(0, -1),
      "GITHUB_API_URL=" + server.url.toString().slice(0, -1),
      "CODER_OWNER_SESSION_TOKEN=foo",
      "CODER_EXTERNAL_AUTH_ID=github",
      "bash",
      "-c",
      instance.script,
    ]);
    expect(exec.stdout).toContain(
      "Your Coder public key is already on GitHub!",
    );
    expect(exec.exitCode).toBe(0);
  });
});

const setupContainer = async (
  image = "lorello/alpine-bash",
  vars: Record<string, string> = {},
) => {
  const server = await setupServer();
  const state = await runTerraformApply(import.meta.dir, {
    agent_id: "foo",
    ...vars,
  });
  const instance = findResourceInstance(state, "coder_script");
  const id = await runContainer(image);
  return { id, instance, server };
};

const setupServer = async (): Promise<Server> => {
  let url: URL;
  const fakeSlackHost = serve({
    fetch: (req) => {
      url = new URL(req.url);
      if (url.pathname === "/api/v2/users/me/gitsshkey") {
        return createJSONResponse({
          public_key: "exists",
        });
      }

      if (url.pathname === "/user/keys") {
        if (req.method === "POST") {
          return createJSONResponse(
            {
              key: "created",
            },
            201,
          );
        }

        // case: key already exists
        if (req.headers.get("Authorization") == "Bearer findkey") {
          return createJSONResponse([
            {
              key: "foo",
            },
            {
              key: "exists",
            },
          ]);
        }

        // case: key does not exist
        return createJSONResponse([
          {
            key: "foo",
          },
        ]);
      }

      return createJSONResponse(
        {
          error: "not_found",
        },
        404,
      );
    },
    port: 0,
  });

  return fakeSlackHost;
};
