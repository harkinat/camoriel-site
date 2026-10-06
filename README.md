# Tales of Camoriel: wiki site

This repo holds the design for the Tales of Camoriel wiki website: the theme, settings and homepage. The campaign notes themselves stay in the private vault repo, `camoriel-wiki`, and are never stored here.

The site is built with [Quartz](https://quartz.jzhao.xyz/) and hosted on Cloudflare Pages. Cloudflare watches the vault repo, so every time Obsidian syncs, the site rebuilds by itself within a couple of minutes.

## How it fits together

1. You write in Obsidian. The Obsidian Git plugin pushes the vault to `camoriel-wiki`.
2. Cloudflare Pages sees the push, clones this repo into `.site`, and runs `build.sh`.
3. `build.sh` fetches a pinned version of Quartz, applies the files in `overlay/`, copies the notes in, and builds the site.

## Cloudflare Pages settings

| Setting | Value |
|---|---|
| Repository | `camoriel-wiki` |
| Production branch | `main` |
| Framework preset | None |
| Build command | `git clone --depth 1 https://github.com/harkinat/camoriel-site .site && bash .site/build.sh` |
| Build output directory | `.site/quartz/public` |
| Environment variable | `NODE_VERSION` = `22` |

## What's in here

| Path | What it does |
|---|---|
| `home.md` | The homepage (party, arcs, places, factions) |
| `overlay/quartz.config.yaml` | Site title, colours, fonts, which features are on |
| `overlay/quartz/styles/custom.scss` | The parchment-and-ink styling |
| `overlay/package*.json`, `overlay/quartz.lock.json` | Exact Quartz package versions |
| `build.sh` | The build Cloudflare runs |
| `scripts/fix-frontmatter.mjs` | Repairs a few malformed note headers from the LegendKeeper import, in the site copy only |

## Keeping notes off the site

These are never published: `CLAUDE.md`, `README.md`, `Dashboard.md`, `.obsidian`, `.trash`, and any top-level folder named `DM Only` or `Private`. A note can also be hidden by adding `draft: true` to its header block.

## Building it yourself

From the root of a copy of the vault:

```
git clone --depth 1 https://github.com/harkinat/camoriel-site .site
bash .site/build.sh
```

You need Node 22 or newer. The site ends up in `.site/quartz/public`.
