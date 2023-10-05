import { describe, expect, it } from "bun:test";
import {
  executeScriptInContainer,
  runTerraformApply,
  runTerraformInit,
  testRequiredVariables,
} from "../test";

describe("azure-region", async () => {
  await runTerraformInit(import.meta.dir);

  testRequiredVariables(import.meta.dir, {});

});
