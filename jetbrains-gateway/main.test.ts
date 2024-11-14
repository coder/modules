import { it, expect, describe } from "bun:test";
import {
  runTerraformInit,
  testRequiredVariables,
  runTerraformApply,
} from "../test";

describe("jetbrains-gateway", async () => {
  await runTerraformInit(import.meta.dir);

  await testRequiredVariables(import.meta.dir, {
    agent_id: "foo",
    agent_name: "foo",
    folder: "/home/foo",
  });

  it("should create a link with the default values", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      agent_name: "foo",
      folder: "/home/coder",
    });
    expect(state.outputs.url.value).toEqual([
      "jetbrains-gateway://connect#type=coder&workspace=default&owner=default&agent=foo&folder=/home/coder&url=https://mydeployment.coder.com&token=$SESSION_TOKEN&ide_product_code=IU&ide_build_number=241.14494.240&ide_download_link=https://download.jetbrains.com/idea/ideaIU-2024.1.tar.gz",
    ]);

    const coder_app = state.resources.find(
      (res) => res.type === "coder_app" && res.name === "gateway",
    );

    expect(coder_app).not.toBeNull();
    expect(coder_app?.instances.length).toBe(1);
    expect(coder_app?.instances[0].attributes.order).toBeNull();
  });

  it("default to first IDE", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      agent_name: "foo",
      folder: "/home/foo",
      jetbrains_ides: ["IU", "PY"],
    });
    expect(state.outputs.identifier.value).toEqual(["IU"]);
    expect(state.outputs.url.value).toEqual([
      "jetbrains-gateway://connect#type=coder&workspace=default&owner=default&agent=foo&folder=/home/foo&url=https://mydeployment.coder.com&token=$SESSION_TOKEN&ide_product_code=IU&ide_build_number=241.14494.240&ide_download_link=https://download.jetbrains.com/idea/ideaIU-2024.1.tar.gz",
    ]);
  });

  it("should create multiple IDEs", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "foo",
      agent_name: "foo",
      folder: "/home/foo",
      default: ["GO", "IU", "PY"],
    });
    expect(state.outputs.identifier.value).toEqual(["GO", "IU", "PY"]);
    expect(state.outputs.url.value).toEqual([
      "jetbrains-gateway://connect#type=coder&workspace=default&owner=default&agent=foo&folder=/home/foo&url=https://mydeployment.coder.com&token=$SESSION_TOKEN&ide_product_code=GO&ide_build_number=241.14494.238&ide_download_link=https://download.jetbrains.com/go/goland-2024.1.tar.gz",
      "jetbrains-gateway://connect#type=coder&workspace=default&owner=default&agent=foo&folder=/home/foo&url=https://mydeployment.coder.com&token=$SESSION_TOKEN&ide_product_code=IU&ide_build_number=241.14494.240&ide_download_link=https://download.jetbrains.com/idea/ideaIU-2024.1.tar.gz",
      "jetbrains-gateway://connect#type=coder&workspace=default&owner=default&agent=foo&folder=/home/foo&url=https://mydeployment.coder.com&token=$SESSION_TOKEN&ide_product_code=PY&ide_build_number=241.14494.241&ide_download_link=https://download.jetbrains.com/python/pycharm-professional-2024.1.tar.gz",
    ]);
  });
});
