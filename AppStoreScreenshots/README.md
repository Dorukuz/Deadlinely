# App Store screenshot assets

Raw simulator captures (iPhone 17 Pro Max, 1320×2868) for marketing frames.

## Location

`AppStoreScreenshots/raw/` — simulator captures

`AppStoreScreenshots/finn/` — still PNGs exported from `Deadlinely/Resources/Finn/*.mov`:

```bash
./scripts/export-finn-pngs.sh
```

Optional: `FRAME_TIME=0.3 ./scripts/export-finn-pngs.sh` to pick a different frame.

| File | Screen |
|------|--------|
| `onboarding-welcome.png` | Onboarding welcome |
| `onboarding-deadline.png` | First deadline step |
| `home-active.png` | Home with 3 active deadlines |
| `home-completed.png` | Active + completed sections |
| `home-empty.png` | Empty home |
| `paywall.png` | Deadlinely Pro paywall |
| `secret-offer.png` | Secret offer sheet |
| `pro-welcome.png` | Pro welcome |
| `widget-tutorial.png` | Widget tutorial intro |
| `editor.png` | Edit deadline sheet |
| `settings.png` | Settings |

## Re-capture

```bash
./scripts/capture-app-store-screenshots.sh
```

Optional: `SIM_ID=<udid> ./scripts/capture-app-store-screenshots.sh`

**If PNGs are blank white:** keep the Simulator app in the foreground (script activates it automatically). Do not run captures headless. You can increase settle time:

```bash
SETTLE_AFTER_READY_SECONDS=3 MIN_LAUNCH_SECONDS=4 ./scripts/capture-app-store-screenshots.sh
```

Debug launch modes use `-ScreenshotMode=<name>` (see `Deadlinely/Debug/ScreenshotLaunchHelper.swift`).

## Design notes

- Drop PNGs into Figma/Sketch device frames for 6.7" and 6.5" listings.
- Add headline copy in the design tool; keep screenshots clean.
- For Lock Screen widget shots, add widgets on the simulator Home Screen and capture separately.
