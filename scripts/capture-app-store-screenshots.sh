#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$ROOT"
DERIVED="${DERIVED:-$HOME/Library/Developer/Xcode/DerivedData/Deadlinely-fqgicmuweagdychberhftnjfesbs}"
OUT_DIR="$ROOT/AppStoreScreenshots/raw"
BUNDLE_ID="Deadlinely.Deadlinely"

# iPhone 17 Pro Max — good source for 6.7" App Store frames
SIM_ID="${SIM_ID:-0D0E82C9-B7C9-43B4-B9E1-DDDC668321AC}"

MODES=(
  "onboarding-welcome"
  "onboarding-deadline"
  "home-active"
  "home-completed"
  "home-empty"
  "paywall"
  "secret-offer"
  "pro-welcome"
  "widget-tutorial"
  "editor"
  "settings"
)

READY_TIMEOUT_SECONDS="${READY_TIMEOUT_SECONDS:-120}"
SETTLE_AFTER_READY_SECONDS="${SETTLE_AFTER_READY_SECONDS:-2.5}"
MIN_LAUNCH_SECONDS="${MIN_LAUNCH_SECONDS:-3}"

mkdir -p "$OUT_DIR"

echo "==> Removing previous screenshots in $OUT_DIR"
rm -f "$OUT_DIR"/*.png

echo "==> Building Debug for simulator ($SIM_ID)"
xcodebuild \
  -project "$PROJECT/Deadlinely.xcodeproj" \
  -scheme Deadlinely \
  -configuration Debug \
  -derivedDataPath "$DERIVED" \
  -destination "platform=iOS Simulator,id=$SIM_ID" \
  build \
  | tail -5

APP="$DERIVED/Build/Products/Debug-iphonesimulator/Deadlinely.app"
if [[ ! -d "$APP" ]]; then
  echo "Missing app bundle at $APP" >&2
  exit 1
fi

echo "==> Booting simulator"
xcrun simctl boot "$SIM_ID" 2>/dev/null || true
open -a Simulator --args -CurrentDeviceUDID "$SIM_ID" 2>/dev/null || true
osascript -e 'tell application "Simulator" to activate' 2>/dev/null || true
sleep 3

echo "==> Installing app"
xcrun simctl install "$SIM_ID" "$APP"

activate_simulator() {
  osascript -e 'tell application "Simulator" to activate' 2>/dev/null || true
  sleep 0.75
}

wait_for_screenshot_ready() {
  local mode="$1"
  local marker="DEADLINELY_SCREENSHOT_READY:${mode}"
  local ready_file
  ready_file="$(mktemp)"
  local log_start
  log_start="$(date -u '+%Y-%m-%dT%H:%M:%S.000Z')"

  xcrun simctl spawn "$SIM_ID" log stream --style compact \
    --start "$log_start" \
    --predicate 'eventMessage CONTAINS "DEADLINELY_SCREENSHOT_READY"' 2>/dev/null \
    | while IFS= read -r line; do
        if [[ "$line" == *"$marker"* ]]; then
          touch "$ready_file"
          break
        fi
      done &
  local watcher_pid=$!

  local elapsed=0
  local quarter_seconds=$((READY_TIMEOUT_SECONDS * 4))
  while [[ ! -f "$ready_file" ]] && [[ $elapsed -lt $quarter_seconds ]]; do
    sleep 0.25
    elapsed=$((elapsed + 1))
  done

  kill "$watcher_pid" 2>/dev/null || true
  wait "$watcher_pid" 2>/dev/null || true
  rm -f "$ready_file"

  if [[ $elapsed -ge $quarter_seconds ]]; then
    echo "    WARN: timed out waiting for $marker — capturing anyway"
  else
    echo "    UI ready ($marker)"
  fi

  sleep "$SETTLE_AFTER_READY_SECONDS"
}

capture_mode() {
  local mode="$1"
  local outfile="$OUT_DIR/${mode}.png"

  echo "==> Launching -ScreenshotMode=$mode"
  xcrun simctl terminate "$SIM_ID" "$BUNDLE_ID" 2>/dev/null || true
  sleep 2

  activate_simulator

  local log_start
  log_start="$(date -u '+%Y-%m-%dT%H:%M:%S.000Z')"
  local marker="DEADLINELY_SCREENSHOT_READY:${mode}"
  local ready_file
  ready_file="$(mktemp)"

  xcrun simctl spawn "$SIM_ID" log stream --style compact \
    --start "$log_start" \
    --predicate 'eventMessage CONTAINS "DEADLINELY_SCREENSHOT_READY"' 2>/dev/null \
    | while IFS= read -r line; do
        if [[ "$line" == *"$marker"* ]]; then
          touch "$ready_file"
          break
        fi
      done &
  local watcher_pid=$!

  xcrun simctl launch "$SIM_ID" "$BUNDLE_ID" "-ScreenshotMode=$mode" >/dev/null
  sleep "$MIN_LAUNCH_SECONDS"

  local elapsed=0
  local quarter_seconds=$((READY_TIMEOUT_SECONDS * 4))
  while [[ ! -f "$ready_file" ]] && [[ $elapsed -lt $quarter_seconds ]]; do
    sleep 0.25
    elapsed=$((elapsed + 1))
  done

  kill "$watcher_pid" 2>/dev/null || true
  wait "$watcher_pid" 2>/dev/null || true
  rm -f "$ready_file"

  if [[ $elapsed -ge $quarter_seconds ]]; then
    echo "    WARN: timed out waiting for $marker — capturing anyway"
  else
    echo "    UI ready ($marker)"
  fi

  activate_simulator
  sleep "$SETTLE_AFTER_READY_SECONDS"

  xcrun simctl io "$SIM_ID" screenshot "$outfile"
  echo "    saved $outfile"
}

for mode in "${MODES[@]}"; do
  capture_mode "$mode"
done

echo ""
echo "Done. Screenshots: $OUT_DIR"
ls -la "$OUT_DIR"
