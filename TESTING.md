# Test log (Android)

Every feature is tested by hand on the emulator (`orcatest` AVD, emulator-5580, 2560x1600 tablet at DPR 2) by
tapping through the UI; phone layout and arm64 hardware follow. Helpers: `run-app.sh` (install, launch, screenshot,
backtrace), `dumptree.sh` (wx window tree with Qt geometry), `files/loglevel` and `files/repaint` debug triggers
(see android/app/bootstrap.cpp, android/app/debugtools.cpp).

Legend: ✅ works · ⚠️ works with issues · ❌ broken · ⏳ not tested yet

## Start-up
| Feature | x86_64 emulator | Notes |
|---|---|---|
| Launch, resources unpack on first start | ✅ | 69 MB zip, ~3 s |
| Language selection (bionic locales) | ✅ | wx falls back to C.UTF-8 |
| Main window (tabs, search, mode, login, sidebar) | ✅ | |
| 3D Plater canvas (GLES 3) | ✅ | bed, toolbar, gizmo bar |
| Configuration Wizard opens on first start | ✅ | |
| Wizard: welcome page text | ✅ | was clipped (wx partial text extents) |
| Wizard: page switch repaint | ✅ | was half stale (Qt Android partial flush of dialogs) |
| Wizard: log-in page web view | ✅ | Prusa Account page loads |
