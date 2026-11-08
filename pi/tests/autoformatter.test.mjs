import assert from "node:assert/strict";
import { mkdir, mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { registerHooks } from "node:module";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { after, before, describe, test } from "node:test";

// Stub only Pi's runtime helpers; configuration and formatter processes are real.
const agentDir = await mkdtemp(join(tmpdir(), "pi-autoformatter-agent-"));
const hooks = registerHooks({
  resolve(specifier, context, nextResolve) {
    if (specifier === "@earendil-works/pi-coding-agent") {
      const source = `
        export const CONFIG_DIR_NAME = '.pi';
        export const getAgentDir = () => ${JSON.stringify(agentDir)};
        export const isWriteToolResult = e => e.toolName === 'write';
        export const isEditToolResult = e => e.toolName === 'edit';
        export const withFileMutationQueue = (_path, fn) => Promise.resolve().then(fn);
      `;
      return { url: `data:text/javascript,${encodeURIComponent(source)}`, shortCircuit: true };
    }
    return nextResolve(specifier, context);
  },
});
const { default: extension } = await import("../extensions/autoformatter/index.ts");
const config = await import("../extensions/autoformatter/config.ts");
const { matchFormatterRule, mergeFormatterRules, parseAutoformatterSection,
  loadEffectiveAutoformatterConfig } = await import("../extensions/autoformatter/config.ts");
const { FORMATTER_OUTPUT_LIMIT, formatterDetails, runFormatterProcess,
  runFormatterForFile } = await import("../extensions/autoformatter/format.ts");
hooks.deregister();

let projectDir;

before(async () => {
  projectDir = await mkdtemp(join(tmpdir(), "pi-autoformatter-"));
});

after(async () => {
  if (projectDir) await rm(projectDir, { recursive: true, force: true });
  await rm(agentDir, { recursive: true, force: true });
});

function rule(overrides = {}) {
  return {
    id: "test",
    extensions: [".ts"],
    command: process.execPath,
    args: [],
    cwd: "project",
    timeoutMs: 1000,
    source: "global",
    ...overrides,
  };
}

describe("autoformatter registration", () => {
  test("registers the tool result handler", () => {
    const handlers = new Map();
    extension({
      on(event, handler) {
        handlers.set(event, handler);
      },
    });

    assert.equal(typeof handlers.get("tool_result"), "function");
  });
});

describe("autoformatter configuration", () => {
  test("loads standalone config and ignores the old settings wrapper", async () => {
    const cwd = await mkdtemp(join(tmpdir(), "pi-autoformatter-config-"));
    try {
      assert.equal(config.globalAutoformatterSettingsPath(), join(agentDir, "autoformatter.json"));
      const path = config.projectAutoformatterSettingsPath(cwd);
      assert.equal(path, join(cwd, ".pi", "autoformatter.json"));
      await mkdir(join(cwd, ".pi"));
      await writeFile(path, JSON.stringify({ formatters: [rule()] }));
      const load = () => loadEffectiveAutoformatterConfig(
        { cwd, isProjectTrusted: () => true }, join(cwd, "test.ts"), new Set(),
      );
      assert.equal((await load()).rules.length, 1);
      await writeFile(path, JSON.stringify({ autoformatter: { formatters: [rule()] } }));
      assert.equal((await load()).rules.length, 0);
    } finally {
      await rm(cwd, { recursive: true, force: true });
    }
  });

  test("parses supported rule fields and defaults", () => {
    const config = parseAutoformatterSection(
      {
        formatters: [
          {
            id: "oxfmt",
            languages: ["typescript"],
            extensions: [".ts", ".tsx"],
            command: "npx",
            args: ["oxfmt", "{file}"],
          },
        ],
      },
      "global",
    );

    assert.deepEqual(config.warnings, []);
    assert.deepEqual(config.rules, [
      {
        id: "oxfmt",
        languages: ["typescript"],
        extensions: [".ts", ".tsx"],
        command: "npx",
        args: ["oxfmt", "{file}"],
        cwd: "project",
        timeoutMs: 10000,
        source: "global",
      },
    ]);
  });

  test("rejects malformed rules without rejecting valid siblings", () => {
    const config = parseAutoformatterSection(
      {
        formatters: [
          { id: "bad", extensions: ["ts"], command: "fmt" },
          { id: "good", extensions: [".ts"], command: "fmt" },
        ],
      },
      "project",
    );

    assert.equal(config.rules.length, 1);
    assert.equal(config.rules[0].id, "good");
    assert.match(config.warnings[0], /dot-prefixed/);
  });

  test("merges project overrides and matches by extension", () => {
    const merged = mergeFormatterRules(
      [
        rule({ id: "web", languages: ["typescript", "javascript"] }),
        rule({ id: "plain", extensions: [".txt"] }),
      ],
      [
        rule({ id: "project-ts", languages: ["typescript"], source: "project" }),
        rule({ id: "plain", extensions: [".md"], source: "project" }),
      ],
    );

    assert.deepEqual(
      merged.map(({ id, languages, source }) => ({ id, languages, source })),
      [
        { id: "project-ts", languages: ["typescript"], source: "project" },
        { id: "plain", languages: undefined, source: "project" },
        { id: "web", languages: ["javascript"], source: "global" },
      ],
    );
    assert.equal(matchFormatterRule(merged, "/project/file.ts")?.id, "project-ts");
    assert.equal(matchFormatterRule(merged, "/project/file.md")?.id, "plain");
  });
});

describe("tool result integration", () => {
  test("formats successful writes and edits, preserving tool content and details", async () => {
    const cwd = await mkdtemp(join(projectDir, "integration-"));
    await mkdir(join(cwd, ".pi"));
    await writeFile(join(cwd, ".pi/autoformatter.json"), JSON.stringify({
      formatters: [rule({
        args: ["-e", "require('node:fs').appendFileSync(process.argv[1], 'formatted')", "{file}"],
      })],
    }));
    const handlers = new Map();
    extension({ on: (name, handler) => handlers.set(name, handler) });
    const handler = handlers.get("tool_result");
    const ctx = { cwd, isProjectTrusted: () => true };
    const target = join(cwd, "example.ts");
    await writeFile(target, "");
    const event = {
      toolName: "write", input: { path: "example.ts" }, isError: false,
      content: [{ type: "text", text: "original" }], details: { original: true },
    };
    for (const toolName of ["write", "edit"]) {
      const patch = await handler({ ...event, toolName }, ctx);
      assert.deepEqual(patch.content[0], event.content[0]);
      assert.equal(patch.details.original, true);
      assert.equal(patch.details.autoformatter.ok, true);
    }
    assert.equal(await readFile(target, "utf8"), "formattedformatted");
    assert.equal(await handler({ ...event, isError: true }, ctx), undefined);
    assert.equal(await handler({ ...event, toolName: "read" }, ctx), undefined);
    assert.equal(await handler({ ...event, input: {} }, ctx), undefined);

    for (const context of [{ cwd }, { cwd, isProjectTrusted: () => false }]) {
      const config = await loadEffectiveAutoformatterConfig(context, target, new Set());
      assert.equal(config.rules.length, 0);
      assert.match(config.projectIgnored, /not trusted/);
    }
    const outside = await loadEffectiveAutoformatterConfig(ctx, join(projectDir, "outside.ts"), new Set());
    assert.equal(outside.rules.length, 0);
    assert.match(outside.projectIgnored, /outside/);

    // Agent edits to config disable that source until a new extension instance.
    await handler({ ...event, input: { path: ".pi/autoformatter.json" } }, ctx);
    const disabled = await handler(event, ctx);
    assert.match(disabled.content.at(-1).text, /ignored until next Pi session/);
    assert.equal(await readFile(target, "utf8"), "formattedformatted");
  });
});

describe("formatter process", () => {
  test("replaces the file placeholder and captures successful output", async () => {
    const targetPath = join(projectDir, "example.ts");
    const result = await runFormatterProcess(
      rule({
        args: ["-e", "process.stdout.write(process.argv[1])", "{file}"],
      }),
      targetPath,
      projectDir,
    );

    assert.equal(result.ok, true);
    assert.equal(result.exitCode, 0);
    assert.equal(result.stdout, targetPath);
  });

  test("caps captured formatter output", async () => {
    const result = await runFormatterProcess(
      rule({
        args: ["-e", `process.stdout.write("x".repeat(${FORMATTER_OUTPUT_LIMIT + 50}))`],
      }),
      join(projectDir, "example.ts"),
      projectDir,
    );

    assert.equal(result.ok, true);
    assert.equal(result.stdout.length, FORMATTER_OUTPUT_LIMIT);
    assert.equal(result.outputTruncated, true);
    assert.equal(formatterDetails(result, []).outputTruncated, true);
  });

  test("reports missing executables, nonzero exits, and timeouts", async () => {
    const target = join(projectDir, "example.ts");
    const missing = await runFormatterProcess(rule({ command: join(projectDir, "missing-command") }), target, projectDir);
    assert.equal(missing.ok, false);
    assert.match(missing.message, /failed to start/);
    const failed = await runFormatterProcess(rule({ args: ["-e", "process.exit(2)"] }), target, projectDir);
    assert.equal(failed.ok, false);
    assert.equal(failed.exitCode, 2);
    const timeout = await runFormatterProcess(rule({ args: ["-e", "setInterval(() => {}, 1000)"], timeoutMs: 50 }), target, projectDir);
    assert.equal(timeout.ok, false);
    assert.match(timeout.message, /timed out/);
  });

  test("coalesces overlapping same-file formatter runs", async () => {
    const target = join(projectDir, "coalesced.ts");
    await writeFile(target, "");
    const formatter = rule({ args: ["-e", "setTimeout(() => require('node:fs').appendFileSync(process.argv[1], 'once'), 50)", "{file}"] });
    const results = await Promise.all([
      runFormatterForFile(formatter, target, projectDir),
      runFormatterForFile(formatter, target, projectDir),
    ]);
    assert.ok(results.every(result => result.ok));
    assert.match(results[1].message, /coalesced/);
    assert.equal(await readFile(target, "utf8"), "once");
  });

  test("reports a missing formatter working directory", async () => {
    const result = await runFormatterProcess(
      rule({ cwd: join(projectDir, "missing") }),
      join(projectDir, "example.ts"),
      projectDir,
    );

    assert.equal(result.ok, false);
    assert.match(result.message, /cwd does not exist/);
  });
});
