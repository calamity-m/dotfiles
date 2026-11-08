import { existsSync } from "node:fs";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/** Discover repository Claude skills alongside Pi's native skills. */
export default function registerClaudeSkillCompatibility(pi: ExtensionAPI) {
  pi.on("resources_discover", (event, ctx) => {
    if (!ctx.isProjectTrusted()) return;

    const skillPath = join(event.cwd, ".claude", "skills");
    if (!existsSync(skillPath)) return;

    return { skillPaths: [skillPath] };
  });
}
