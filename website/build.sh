#!/usr/bin/env bash
# Coolify / CI: must produce ./dist (nginx COPY target).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

if [[ ! -d public ]]; then
  echo "ERROR: public/ not found in $ROOT" >&2
  exit 1
fi

rm -rf dist
mkdir -p dist
cp -R public/. dist/

if [[ ! -f dist/index.html ]]; then
  echo "ERROR: dist/index.html missing after copy" >&2
  exit 1
fi

echo "OK: built dist/ with $(find dist -type f | wc -l | tr -d ' ') files"
