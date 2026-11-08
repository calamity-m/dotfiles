import assert from "node:assert/strict";
import { mkdir, mkdtemp, rm, writeFile } from "node:fs/promises";
import { registerHooks } from "node:module";
import { homedir, tmpdir } from "node:os";
import { join } from "node:path";
import { after, before, test } from "node:test";
import { pathToFileURL } from "node:url";

// Pi provides this runtime import inside the harness. Stub only its type guard
// so these tests also run without installing Pi's npm packages in the dotfiles.
const hooks = registerHooks({
  resolve(specifier, context, nextResolve) {
    if (specifier === "@earendil-works/pi-coding-agent") {
      return {
        url: "data:text/javascript,export const isReadToolResult = event => event.toolName === 'read';",
        shortCircuit: true,
      };
    }
    return nextResolve(specifier, context);
  },
});
const {
  default: extension,
  findApplicableNestedContextFiles,
  resolveReadInputPath,
  renderNestedContextFiles,
} = await import("../extensions/nested-context.ts");
hooks.deregister();

let root;
before(async () => {
  root = await mkdtemp(join(tmpdir(), "pi-nested-context-"));
  await mkdir(join(root, "src", "deep"), { recursive: true });
  await mkdir(join(root, "fallback", "AGENTS.md"), { recursive: true });
  for (const [file, content] of [
    ["AGENTS.md", "root rules"],
    ["src/AGENTS.md", "src rules"],
    ["src/CLAUDE.md", "lower priority rules"],
    ["src/deep/AGENTS.MD", "deep rules"],
    ["src/deep/a.ts", "a"],
    ["src/deep/b.ts", "b"],
    ["fallback/CLAUDE.md", "fallback rules"],
    ["fallback/c.ts", "c"],
  ]) await writeFile(join(root, file), content);
});
after(async () => { await rm(root, { recursive: true, force: true }); });

function setup(contextFiles = []) {
  const handlers = new Map();
  extension({ on: (name, handler) => handlers.set(name, handler) });
  const ctx = { cwd: root };
  handlers.get("session_start")({}, ctx);
  const seed = () => handlers.get("before_agent_start")({
    systemPromptOptions: { cwd: ctx.cwd, contextFiles },
  }, ctx);
  seed();
  const read = (path, options = {}, overrides = {}) => handlers.get("tool_result")({
    toolName: "read",
    input: { path, ...options },
    content: [{ type: "text", text: "original result" }],
    isError: false,
    ...overrides,
  }, ctx);
  return { handlers, ctx, seed, read };
}

const srcContext = () => join(root, "src", "AGENTS.md");
const deepContext = () => join(root, "src", "deep", "AGENTS.MD");

test("discovers nested files outermost-first, excluding cwd and lower-priority alternatives", () => {
  assert.deepEqual(findApplicableNestedContextFiles(root, "src/deep/a.ts"), [srcContext(), deepContext()]);
});

test("excludes the context file being explicitly read", () => {
  assert.deepEqual(findApplicableNestedContextFiles(root, deepContext()), [srcContext()]);
});

test("ignores root-level files and paths outside cwd", () => {
  for (const target of ["a.ts", "../outside/a.ts", `${root}-sibling/a.ts`]) {
    assert.deepEqual(findApplicableNestedContextFiles(root, target), []);
  }
});

test("falls back to CLAUDE.md when AGENTS.md is a directory", () => {
  assert.deepEqual(findApplicableNestedContextFiles(root, "fallback/c.ts"), [join(root, "fallback", "CLAUDE.md")]);
});

test("resolves relative, absolute, @, file URL, and home paths", () => {
  const target = join(root, "src", "deep", "a.ts");
  for (const input of ["src/deep/a.ts", "@src/deep/a.ts", target, pathToFileURL(target).href]) {
    assert.equal(resolveReadInputPath(root, input), target);
  }
  assert.equal(resolveReadInputPath(root, "~"), homedir());
  assert.equal(resolveReadInputPath(root, "~/example.ts"), join(homedir(), "example.ts"));
});

test("appends instructions while preserving original content and deduplicates across turns", async () => {
  const { read, seed } = setup();
  const first = await read("src/deep/a.ts");
  assert.equal(first.content[0].text, "original result");
  assert.match(first.content[1].text, /src rules/);
  assert.match(first.content[1].text, /deep rules/);
  assert.doesNotMatch(first.content[1].text, /root rules|lower priority rules/);
  seed();
  assert.equal(await read("src/deep/b.ts"), undefined);
});

test("does not reinject files already loaded by Pi", async () => {
  const { read } = setup([{ path: srcContext(), content: "src rules" }]);
  const result = await read("src/deep/a.ts");
  assert.doesNotMatch(result.content[1].text, /src rules/);
  assert.match(result.content[1].text, /deep rules/);
});

test("reserves instructions before async IO to prevent duplicate parallel injection", async () => {
  const { read } = setup();
  const results = await Promise.all([read("src/deep/a.ts"), read("src/deep/b.ts")]);
  const injected = results.filter(Boolean);
  assert.equal(injected.length, 1);
  assert.match(injected[0].content[1].text, /src rules/);
  assert.match(injected[0].content[1].text, /deep rules/);
});

test("failed reads and non-read tools do not consume instructions", async () => {
  const { read } = setup();
  assert.equal(await read("src/deep/a.ts", {}, { isError: true }), undefined);
  assert.equal(await read("src/deep/a.ts", {}, { toolName: "edit" }), undefined);
  assert.equal(await read(undefined), undefined);
  assert.ok(await read("src/deep/a.ts"));
});

test("explicit full context reads are not injected again later", async () => {
  const { read } = setup();
  const result = await read("src/deep/AGENTS.MD");
  assert.match(result.content[1].text, /src rules/);
  assert.doesNotMatch(result.content[1].text, /deep rules/);
  assert.equal(await read("src/deep/a.ts"), undefined);
});

test("partial explicit context reads do not suppress later injection", async () => {
  const { read } = setup();
  await read("src/deep/AGENTS.MD", { limit: 1 });
  const result = await read("src/deep/a.ts");
  assert.match(result.content[1].text, /deep rules/);
});

test("session start resets injection state", async () => {
  const { handlers, ctx, seed, read } = setup();
  await read("src/deep/a.ts");
  handlers.get("session_start")({}, ctx);
  seed();
  assert.ok(await read("src/deep/b.ts"));
});

test("cwd changes reset state and use the new discovery boundary", async () => {
  const { ctx, seed, read } = setup();
  await read("src/deep/a.ts");
  ctx.cwd = join(root, "src");
  seed();
  const result = await read("deep/b.ts");
  assert.match(result.content[1].text, /deep rules/);
  assert.doesNotMatch(result.content[1].text, /src rules/);
});

test("escapes XML path attributes without changing instruction text", () => {
  const rendered = renderNestedContextFiles(root, [{
    path: join(root, 'a&"<>', "AGENTS.md"), content: "Use <T> & keep rules",
  }]);
  assert.match(rendered, /a&amp;&quot;&lt;&gt;/);
  assert.match(rendered, /Use <T> & keep rules/);
});
