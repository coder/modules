import { readFile, readdir, stat } from "fs/promises";
import * as path from "path";
import * as marked from "marked";

const files = await readdir(".", { withFileTypes: true });
const dirs = files.filter(
  (f) => f.isDirectory() && !f.name.startsWith(".") && f.name !== "node_modules"
);

let badExit = false

// Ensures that each README has the proper format.
// Exits with 0 if all is good!
for (const dir of dirs) {
  const readme = path.join(dir.name, "README.md");
  // Ensure exists
  try {
    await stat(readme);
  } catch (ex) {
    throw new Error(`Missing README.md in ${dir.name}`);
  }
  const content = await readFile(readme, "utf8");
  const tokens = marked.lexer(content);
  // Ensure there is an h1 and some text, then a code block

  let h1 = false;
  let code = false;
  let paragraph = false;

  for (const token of tokens) {
    if (token.type === "heading" && token.depth === 1) {
      h1 = true;
      continue;
    }
    if (h1 && token.type === "heading") {
      break;
    }
    if (token.type === "paragraph") {
      paragraph = true;
      continue;
    }
    if (token.type === "code") {
      code = true;
      continue;
    }
  }
  if (!h1) {
    console.error(dir.name, "missing h1")
  }
  if (!paragraph) {
    console.error(dir.name, "missing paragraph after h1")
  }
  if (!code) {
    console.error(dir.name, "missing example code block after paragraph")
  }
  badExit = true
}

if (badExit) {
    process.exit(1)
}
