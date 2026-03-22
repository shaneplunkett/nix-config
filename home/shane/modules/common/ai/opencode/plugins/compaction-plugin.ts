import type { Plugin } from "@opencode-ai/plugin"
import { readFileSync } from "node:fs"
import { homedir } from "node:os"
import { join } from "node:path"

export const CompactionPlugin: Plugin = async (ctx) => {
  return {
    "experimental.session.compacting": async (input, output) => {
      const path = join(homedir(), ".config", "opencode", "vex", "compaction.md")
      try {
        const context = readFileSync(path, "utf-8")
        output.context.push(context)
      } catch {}
    }
  }
}
