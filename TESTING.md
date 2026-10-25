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
| Wizard: updates, downloads, reload-from-disk, view mode (radio buttons), Finish | ✅ | |
| Send-system-info dialog, verbatim data dialog | ✅ | verbatim dialog opens top-left, not centred |
| Main window after the wizard (CORE One INDX: 4 tools, bed texture) | ✅ | |
| TopBar Menu (File/Edit/Window/View/Configuration/Help, submenus) | ✅ | was Qt's Android action bar with no menus |
| Add (import OBJ) through the Android file picker | ✅ | |
| File > Open Project (3MF with presets) | ✅ | picker's Recent view was empty; Downloads works |
| Slice now | ✅ | 3DBenchy, 320 layers, 1h4m |
| G-code preview (libvgcode GLES), legend, sliders shown | ✅ | |
| App update check / "new prerelease" notification on Android | ⚠️ | desktop installer, should be off |
