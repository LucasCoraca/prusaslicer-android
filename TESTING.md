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
| Wizard: log-in page, Prusa Account form, cookie banner, typing | ✅ | was 4x zoomed (web view laid out 1x1 first) |
| Wizard: configuration sources, check boxes toggle | ✅ | ticks were never drawn (wxQt toggle button bitmap) |
| Wizard: profile download over HTTPS | ✅ | all vendors, ~1 min on the emulator |
| Wizard: printer pages, touch scrolling | ✅ | page had viewport height (no size event when size unchanged) |
| Wizard: pick a printer (XL 5T 0.4) | ✅ | crashed in QScrollArea::ensureWidgetVisible (wxQt scroll area) |
| Wizard: page index overlaps the logo when many pages | ⚠️ | cosmetic |
| Small native check boxes (~14 px) | ⚠️ | hard to hit with a finger |
| Wizard: filaments page, type/vendor filter | ✅ | filtered by the previous item (wxEVT_LISTBOX before selection) |
| Wizard: filament check list toggle | ✅ | |
