#!/usr/bin/env bash
# Export still PNGs from Finn .mov loops (RGBA, mid-animation frame).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FINN_DIR="$ROOT/Deadlinely/Resources/Finn"
OUT_DIR="${1:-$ROOT/AppStoreScreenshots/finn}"

# Seconds into each loop — tweak per clip if a pose looks better earlier/later.
FRAME_TIME="${FRAME_TIME:-0.5}"

mkdir -p "$OUT_DIR"

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg is required (brew install ffmpeg)" >&2
  exit 1
fi

shopt -s nullglob
movs=("$FINN_DIR"/*.mov)
if [[ ${#movs[@]} -eq 0 ]]; then
  echo "No .mov files in $FINN_DIR" >&2
  exit 1
fi

echo "Exporting Finn PNGs → $OUT_DIR (t=${FRAME_TIME}s)"
for mov in "${movs[@]}"; do
  base="$(basename "$mov" .mov)"
  out="$OUT_DIR/${base}.png"
  ffmpeg -hide_banner -loglevel error -y \
    -ss "$FRAME_TIME" \
    -i "$mov" \
    -frames:v 1 \
    -update 1 \
    "$out"
  echo "  $out"
done

echo "Done. ${#movs[@]} files in $OUT_DIR"
