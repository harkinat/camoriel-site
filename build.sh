#!/usr/bin/env bash
# Builds the Tales of Camoriel wiki site.
#
# Run from the root of the vault repo (camoriel-wiki), after this repo has been
# cloned into ./.site. Cloudflare does exactly that:
#
#   Build command:   git clone --depth 1 https://github.com/harkinat/camoriel-site .site && bash .site/build.sh
#   Deploy command:  cd .site && npx wrangler@4 deploy
#
# The finished site ends up in .site/quartz/public.
set -euo pipefail

QUARTZ_REPO="https://github.com/jackyzha0/quartz.git"
QUARTZ_COMMIT="97a2d05f80c4c50534959b1d0d41cc4b3895625e"   # Quartz 5, pinned so builds don't break unexpectedly

VAULT="$(pwd)"
SITE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QUARTZ="$SITE/quartz"

echo "==> Fetching Quartz ($QUARTZ_COMMIT)"
rm -rf "$QUARTZ"
git init -q "$QUARTZ"
git -C "$QUARTZ" fetch -q --depth 1 "$QUARTZ_REPO" "$QUARTZ_COMMIT"
git -C "$QUARTZ" checkout -q FETCH_HEAD

echo "==> Applying Camoriel theme and settings"
cp -R "$SITE/overlay/." "$QUARTZ/"
if [ -n "${SITE_URL:-}" ]; then
  # Optional: set SITE_URL in Cloudflare (e.g. camoriel.pages.dev) for correct sitemap/RSS links
  sed -i "s|^  baseUrl: .*|  baseUrl: ${SITE_URL#https://}|" "$QUARTZ/quartz.config.yaml"
fi

echo "==> Installing dependencies"
cd "$QUARTZ"
npm ci --no-audit --no-fund
npx quartz plugin install

echo "==> Copying notes from the vault"
rm -rf "$QUARTZ/content"
mkdir -p "$QUARTZ/content"
# Everything in the vault except tooling, private files and Obsidian internals.
tar -C "$VAULT" \
  --exclude=./.git --exclude=./.gitignore --exclude=./.github --exclude=./.site --exclude=./.obsidian \
  --exclude=./.claude --exclude=./.trash \
  --exclude=./CLAUDE.md --exclude=./README.md --exclude=./Dashboard.md \
  --exclude='./DM Only' --exclude='./Private' \
  -cf - . | tar -C "$QUARTZ/content" -xf -
cp "$SITE/home.md" "$QUARTZ/content/index.md"
node "$SITE/scripts/fix-frontmatter.mjs" "$QUARTZ/content"

echo "==> Building the site"
npx quartz build
echo "==> Done: $QUARTZ/public"
