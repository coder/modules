import { describe, expect, it } from "vitest";
import { TerraformStack } from "cdktf";
import { generateTraces } from "@coder/cdktf-traces";
import { CoderApp } from "../../cdktf/coder/resources";

describe("windsurf", async () => {
  const traces = await generateTraces(__dirname);

  it("creates an app", () => {
    const stack = new TerraformStack(traces.app, "stack");
    const app = CoderApp.fromStack<CoderApp>(stack, "coder_app.windsurf");
    expect(app.url).toContain("workspace=");
    expect(app.url).toContain("token=$SESSION_TOKEN");
    expect(app.icon).toBe("/icon/windsurf.svg");
    expect(app.slug).toBe("windsurf");
    expect(app.displayName).toBe("Windsurf IDE");
    expect(app.external).toBe(true);
  });

  describe("supports folder spec", () => {
    it("folder = '/home/coder'", async () => {
      const traces = await generateTraces(__dirname, {
        folder: "/home/coder",
      });
      const stack = new TerraformStack(traces.app, "stack");
      const app = CoderApp.fromStack<CoderApp>(stack, "coder_app.windsurf");
      expect(app.url).toContain("&folder=/home/coder");
    });
  });

  describe("supports openRecent", () => {
    it("open_recent = true", async () => {
      const traces = await generateTraces(__dirname, {
        open_recent: true,
      });
      const stack = new TerraformStack(traces.app, "stack");
      const app = CoderApp.fromStack<CoderApp>(stack, "coder_app.windsurf");
      expect(app.url).toContain("&openRecent");
    });
  });
});