#!/usr/bin/env bash
# Coolify / CI: must produce ./dist (nginx COPY target).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

SITE_URL="${SITE_URL:-https://deadlinely.gatex.uk}"
SITE_URL="${SITE_URL%/}"

if [[ ! -d public ]]; then
  echo "ERROR: public/ not found in $ROOT" >&2
  exit 1
fi

rm -rf dist
mkdir -p dist
cp -R public/. dist/

# Absolute URLs in built HTML so links never resolve to localhost behind a misconfigured proxy.
for html in dist/*.html; do
  [[ -f "$html" ]] || continue
  tmp="$(mktemp)"
  sed \
    -e "s|href=\"/|href=\"${SITE_URL}/|g" \
    -e "s|src=\"/|src=\"${SITE_URL}/|g" \
    "$html" > "$tmp"
  mv "$tmp" "$html"
done

if [[ ! -f dist/index.html ]]; then
  echo "ERROR: dist/index.html missing after copy" >&2
  exit 1
fi

if grep -q 'localhost' dist/*.html 2>/dev/null; then
  echo "ERROR: dist still contains localhost — check SITE_URL=${SITE_URL}" >&2
  exit 1
fi

echo "OK: built dist/ with $(find dist -type f | wc -l | tr -d ' ') files (SITE_URL=${SITE_URL})"
