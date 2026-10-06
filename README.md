# Tales of Camoriel: wiki site

This repo holds the design for the Tales of Camoriel wiki website: the theme, settings and homepage. The campaign notes themselves stay in the private vault repo, `camoriel-wiki`, and are never stored here.

The site is built with [Quartz](https://quartz.jzhao.xyz/) and hosted on Cloudflare. Cloudflare watches the vault repo, so every time Obsidian syncs, the site rebuilds by itself within a couple of minutes.

## How it fits together

1. You write in Obsidian. The Obsidian Git plugin pushes the vault to `camoriel-wiki`.
2. Cloudflare sees the push, clones this repo into `.site`, and runs `build.sh`.
3. `build.sh` fetches a pinned version of Quartz, applies the files in `overlay/`, copies the notes in, and builds the site.

## Cloudflare settings

The site runs as a Cloudflare Worker that only serves the built files (set up under **Workers & Pages → Create application → Import a repository**).

| Setting | Value |
|---|---|
| Repository | `camoriel-wiki` |
| Project name | `camoriel-wiki` (must match `name` in `wrangler.jsonc`) |
| Build command | `git clone --depth 1 https://github.com/harkinat/camoriel-site .site && bash .site/build.sh` |
| Deploy command | `cd .site && npx wrangler@4 deploy` |
| Preview builds | Off |
| Build variable | `NODE_VERSION` = `22` |

## What's in here

| Path | What it does |
|---|---|
| `home.md` | The homepage (party, arcs, places, factions) |
| `overlay/quartz.config.yaml` | Site title, colours, fonts, which features are on |
| `overlay/quartz/styles/custom.scss` | The parchment-and-ink styling |
| `overlay/package*.json`, `overlay/quartz.lock.json` | Exact Quartz package versions |
| `build.sh` | The build Cloudflare runs |
| `wrangler.jsonc` | Tells Cloudflare to serve the built site |
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
