import { describe, expect, it } from "bun:test";
import {
  runTerraformApply,
  runTerraformInit,
  testRequiredVariables,
} from "../test";

describe("code-server", async () => {
  await runTerraformInit(import.meta.dir);

  testRequiredVariables(import.meta.dir, {
    agent_id: "foo",
  });

  it("use_cached and offline can not be used together", () => {
    const t = async () => {
      await runTerraformApply(import.meta.dir, {
        agent_id: "foo",
        use_cached: "true",
        offline: "true",
      });
    };
    expect(t).toThrow("Offline and Use Cached can not be used together");
  });

  it("offline and extensions can not be used together", () => {
    const t = async () => {
      await runTerraformApply(import.meta.dir, {
        agent_id: "foo",
        offline: "true",
        extensions: '["1", "2"]',
      });
    };
    expect(t).toThrow("Offline mode does not allow extensions to be installed");
  });

  // More tests depend on shebang refactors
});
