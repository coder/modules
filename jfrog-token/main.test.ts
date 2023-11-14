import { serve } from "bun";
import { describe } from "bun:test";
import {
  createJSONResponse,
  runTerraformInit,
  testRequiredVariables,
} from "../test";

describe("jfrog-token", async () => {
  await runTerraformInit(import.meta.dir);

  // Run a fake JFrog server so the provider can initialize
  // correctly. This saves us from having to make remote requests!
  const fakeFrogHost = serve({
    fetch: (req) => {
      const url = new URL(req.url);
      // See https://jfrog.com/help/r/jfrog-rest-apis/license-information
      if (url.pathname === "/artifactory/api/system/license")
        return createJSONResponse({
          type: "Commercial",
          licensedTo: "JFrog inc.",
          validThrough: "May 15, 2036",
        });
      if (url.pathname === "/access/api/v1/tokens")
        return createJSONResponse({
          token_id: "xxx",
          access_token: "xxx",
          scopes: "any",
        });
      return createJSONResponse({});
    },
    port: 0,
  });

  testRequiredVariables(import.meta.dir, {
    agent_id: "some-agent-id",
    jfrog_url: "http://" + fakeFrogHost.hostname + ":" + fakeFrogHost.port,
    artifactory_access_token: "XXXX",
    package_managers: "{}",
  });
});
