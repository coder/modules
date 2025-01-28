import { readableStreamToText, spawn } from "bun";
import { afterAll, beforeAll } from "bun:test";

const removeStatefiles = async () => {
  const proc = spawn([
    "find",
    ".",
    "-type",
    "f",
    "-o",
    "-name",
    "*.tfstate",
    "-o",
    "-name",
    "*.tfstate.lock.info",
    "-delete",
  ]);
  await proc.exited;
};

const removeOldContainers = async () => {
  let proc = spawn([
    "docker",
    "ps",
    "-a",
    "-q",
    "--filter",
    "label=modules-test",
  ]);
  let containerIDsRaw = await readableStreamToText(proc.stdout);
  let exitCode = await proc.exited;
  if (exitCode !== 0) {
    throw new Error(containerIDsRaw);
  }
  containerIDsRaw = containerIDsRaw.trim();
  if (containerIDsRaw === "") {
    return;
  }
  proc = spawn(["docker", "rm", "-f", ...containerIDsRaw.split("\n")]);
  const stdout = await readableStreamToText(proc.stdout);
  exitCode = await proc.exited;
  if (exitCode !== 0) {
    throw new Error(stdout);
  }
};

afterAll(async () => {
  await Promise.all([removeStatefiles(), removeOldContainers()]);
});
