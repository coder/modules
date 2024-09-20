import { describe, expect, it } from "bun:test";
import {
  findResourceInstance,
  runTerraformInit,
  runTerraformApply,
  testRequiredVariables,
} from "../test";

describe("jfrog-oauth", async () => {
  await runTerraformInit(import.meta.dir);

  const fakeFrogHostAndPort = "localhost:8081";
  const fakeFrogUrl = `http://${fakeFrogHostAndPort}`;

  it("can run apply with required variables", async () => {
    testRequiredVariables(import.meta.dir, {
      agent_id: "some-agent-id",
      jfrog_url: fakeFrogUrl,
      package_managers: "{}",
    });
  });

  it("generates an npmrc with scoped repos", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "some-agent-id",
      jfrog_url: fakeFrogUrl,
      package_managers: JSON.stringify({
        npm: ["global", "@foo:foo", "@bar:bar"],
      }),
    });
    const coderScript = findResourceInstance(state, "coder_script");
    const npmrcStanza = `cat << EOF > ~/.npmrc
email=default@example.com
registry=${fakeFrogUrl}/artifactory/api/npm/global
//${fakeFrogHostAndPort}/artifactory/api/npm/global/:_authToken=
@foo:registry=${fakeFrogUrl}/artifactory/api/npm/foo
//${fakeFrogHostAndPort}/artifactory/api/npm/foo/:_authToken=
@bar:registry=${fakeFrogUrl}/artifactory/api/npm/bar
//${fakeFrogHostAndPort}/artifactory/api/npm/bar/:_authToken=

EOF`;
    expect(coderScript.script).toContain(npmrcStanza);
    expect(coderScript.script).toContain(
      'jf npmc --global --repo-resolve "global"',
    );
    expect(coderScript.script).toContain(
      'if [ -z "YES" ]; then\n  not_configured npm',
    );
  });

  it("generates a pip config with extra-indexes", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "some-agent-id",
      jfrog_url: fakeFrogUrl,
      package_managers: JSON.stringify({
        pypi: ["global", "foo", "bar"],
      }),
    });
    const coderScript = findResourceInstance(state, "coder_script");
    const pipStanza = `cat << EOF > ~/.pip/pip.conf
[global]
index-url = https://default:@${fakeFrogHostAndPort}/artifactory/api/pypi/global/simple
extra-index-url =
    https://default:@${fakeFrogHostAndPort}/artifactory/api/pypi/foo/simple
    https://default:@${fakeFrogHostAndPort}/artifactory/api/pypi/bar/simple

EOF`;
    expect(coderScript.script).toContain(pipStanza);
    expect(coderScript.script).toContain(
      'jf pipc --global --repo-resolve "global"',
    );
    expect(coderScript.script).toContain(
      'if [ -z "YES" ]; then\n  not_configured pypi',
    );
  });

  it("registers multiple docker repos", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "some-agent-id",
      jfrog_url: fakeFrogUrl,
      package_managers: JSON.stringify({
        docker: ["foo.jfrog.io", "bar.jfrog.io", "baz.jfrog.io"],
      }),
    });
    const coderScript = findResourceInstance(state, "coder_script");
    const dockerStanza = `register_docker "foo.jfrog.io"
register_docker "bar.jfrog.io"
register_docker "baz.jfrog.io"`;
    expect(coderScript.script).toContain(dockerStanza);
    expect(coderScript.script).toContain(
      'if [ -z "YES" ]; then\n  not_configured docker',
    );
  });

  it("sets goproxy with multiple repos", async () => {
    const state = await runTerraformApply(import.meta.dir, {
      agent_id: "some-agent-id",
      jfrog_url: fakeFrogUrl,
      package_managers: JSON.stringify({
        go: ["foo", "bar", "baz"],
      }),
    });
    const proxyEnv = findResourceInstance(state, "coder_env", "goproxy");
    const proxies = `https://default:@${fakeFrogHostAndPort}/artifactory/api/go/foo,https://default:@${fakeFrogHostAndPort}/artifactory/api/go/bar,https://default:@${fakeFrogHostAndPort}/artifactory/api/go/baz`;
    expect(proxyEnv["value"]).toEqual(proxies);

    const coderScript = findResourceInstance(state, "coder_script");
    expect(coderScript.script).toContain(
      'jf goc --global --repo-resolve "foo"',
    );
    expect(coderScript.script).toContain(
      'if [ -z "YES" ]; then\n  not_configured go',
    );
  });
});
