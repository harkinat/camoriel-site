// Repairs a few malformed note headers left over from the LegendKeeper import,
// so one broken note can't stop the whole site from building.
// It only changes the copy used for the website, never the vault itself.
//
// Handles:
//   - a stray "---" line at the top with no closing "---"
//   - a doubled "---" right after a valid header block
//   - "## type: x" / "region: y" lines that should have been a header block
import { readdirSync, readFileSync, writeFileSync, statSync } from "node:fs"
import { join } from "node:path"

const root = process.argv[2]
if (!root) {
  console.error("usage: fix-frontmatter.mjs <content-dir>")
  process.exit(1)
}

function* walk(dir) {
  for (const name of readdirSync(dir)) {
    const p = join(dir, name)
    if (statSync(p).isDirectory()) yield* walk(p)
    else if (name.endsWith(".md")) yield p
  }
}

let fixed = 0
for (const file of walk(root)) {
  const original = readFileSync(file, "utf8")
  let text = original.replace(/\r\n/g, "\n")
  let header = null

  // A real header block only contains "key: value" lines (or indented list items).
  const looksLikeYaml = (block) =>
    block.trim() !== "" &&
    block.split("\n").every((l) => l.trim() === "" || /^[\w-]+:/.test(l) || /^\s+/.test(l))

  const valid = text.match(/^---\n([\s\S]*?)\n---\n/)
  if (valid && looksLikeYaml(valid[1])) {
    header = valid[1]
    text = text.slice(valid[0].length).replace(/^---\n/, "") // drop a doubled separator
  } else if (text.startsWith("---\n")) {
    text = text.slice(4) // stray opening separator
  }

  // "## type: item" (and optionally "region: overland") written as body text
  text = text.replace(/^\s*/, "")
  const loose = text.match(/^## [Tt]ype: *(\S+) *\n(?:\s*region: *(\S+) *\n)?/)
  if (loose) {
    text = text.slice(loose[0].length)
    if (!header) header = `type: ${loose[1]}` + (loose[2] ? `\nregion: ${loose[2]}` : "")
  }

  const result = (header ? `---\n${header}\n---\n` : "") + text.replace(/^\n+/, "")
  if (result !== original.replace(/\r\n/g, "\n")) {
    writeFileSync(file, result)
    fixed++
  }
}
console.log(`fix-frontmatter: repaired ${fixed} note header(s)`)
