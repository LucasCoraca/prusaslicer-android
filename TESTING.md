# Test log (Android)

Every feature is tested by hand on the emulator (`pstab` tablet and `psphone` phone AVDs, emulator-5580) by tapping
through the UI; arm64 hardware follows. Helpers: `run-app.sh` (install, launch, screenshot,
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
| Export G-code through the Android save dialog | ✅ | .bgcode lands in Downloads; notification shows the cache path |
| 3D view: one-finger orbit | ✅ | |
| 3D view: pinch zoom in/out (toward the fingers), two-finger pan, twist | ✅ | PrusaSlicer had no gesture handling; added |
| Import STL, drag object on the bed | ✅ | |
| Long press = right click: object context menu | ✅ | |
| Add instance, Arrange | ✅ | |
| Move gizmo (axis drag), Rotate gizmo (ring drag) | ✅ | |
| Cut gizmo: ImGui panel, edit cut height, Perform cut | ✅ | |
| Print Settings tab: page tree | ✅ | was empty: wxQt SetIndent() set the column count |
| Memory | ⚠️ | PrusaSlicer needs ~1.2 GB resident, 2.7 GB peak while loading the Prusa profiles (same as desktop); 4 GB phones may be tight |

| Settings pages render (DPR 1 tablet AVD), unit labels | ✅ | crash on empty bitmap in wxQt DrawBitmap; units slid under fields |
| Edit a value (spin), modified marker, reset to system value | ✅ | |
| Switch settings pages | ✅ | |
| Drop-down lists (all PrusaSlicer combo boxes) open and select | ✅ | three bugs: hidden maximized frame on top (wxQt Maximize showed it), popups inherited disabled updates from a frozen parent, DropDown lost its pick when hidden |
| Save preset dialog, type a name, save user preset | ✅ | dialogs with Layout()+Fit() recursed to a stack overflow (synchronous Qt resize) |
| Soft keyboard over dialogs | ✅ | dialog moved above the keyboard (was covered) |
| Save preset dialog heading label | ⚠️ | missing |
| Filaments tab, colour picker (QColorDialog), modified marker | ✅ | dialogs were at the top-left: now centred when first shown |
| Printers tab, Bed shape dialog (2D preview, Shape choice, Circular) | ✅ | native combo boxes never opened on tap: now open on release |
| Configuration menu, Preferences dialog: check boxes, tabs | ✅ | taps lost in dialogs with scroll areas: touch points carried the window offset |

## Phone layout (`psphone` AVD, 720x1520 at DPR 2 = 360x760 dp)
Phones (smaller screen side under 600 dp, `PhoneLayout.hpp`; `PS_LAYOUT=phone|tablet` forces one) get a narrow-screen
layout of the same GUI.

| Feature | x86_64 emulator | Notes |
|---|---|---|
| Top bar: icon buttons (menu, pages, mode, account), search field below | ✅ | landscape: search in the button row |
| Plater portrait: 3D view above the sidebar (42 %, scrolls) | ✅ | collapse button always shown |
| Plater landscape: sidebar on the right, at most half the width | ✅ | |
| Settings tabs portrait: preset combo above its buttons, page drop-down instead of the tree | ✅ | |
| Settings tabs landscape: desktop arrangement (tree beside page) | ✅ | switches on rotation |
| Option labels wrap (13 em), description texts wrap (28 em) | ✅ | |
| Multi-option rows (Solid layers Top/Bottom, temperatures) one option per row | ✅ | |
| Search: type, results list, jump to option | ✅ | results went behind the main window (Qt Android ignores stay-on-top); keyboard held words uncommitted (predictive text) |
| Configuration Wizard full screen, no page index, texts wrapped, 2 printers per row, 2x2 filament lists | ✅ | |
| Wizard first run on a fresh device, profile download, Finish | ✅ | |
| Wizard / scrolled pages repaint | ✅ | scroll blits and page switches left stale strips at DPR 2: full repaint |
| Import STL through the Android picker, object manipulation panel | ✅ | |
| Slice, preview, legend | ✅ | legend starts collapsed |
| Preferences: wrapped labels, left-aligned fields | ✅ | check boxes were pushed off screen by right alignment |
| Check box / radio indicators | ✅ | 20 dp minimum on Android (proxy style) |
| Desktop app update check and system info dialog | ✅ | disabled on Android |
| Context menu (long press), add/remove instance, move gizmo drag, collapse sidebar | ✅ | |
| Physical printer dialog | ✅ | texts of too-wide dialogs wrap when first shown (wxQt) |
| Compare presets dialog | ✅ | presets above each other |
| Bed shape dialog | ✅ | preview above the settings |
| Unsaved changes dialog (switch preset), Discard | ✅ | |
| Description texts re-wrap after a value change | ✅ | wx 3.3 Wrap() skipped a new label with the same width |
| Printables tab | ✅ | mobile site |
| Workspace mode menu (Expert) | ✅ | menu button stayed highlighted (no wxEVT_MENU_CLOSE in wxQt) |
| Preview sliders (layers, moves) drag, legend expand/collapse | ✅ | after a fast swipe the last frame came with the next input: extra frame |
| Export G-code through the Android save dialog | ✅ | |
| Error / message dialogs | ✅ | no logo on a phone, message box narrower and taller |
| Notifications and hints | ✅ | 20 line heights wide on a phone (was wider than the 3D view) |
| Object list columns | ✅ | Name column 15 em on a phone |
| Dialog titles | ⚠️ | Android shows no window titles (e.g. Save preset has no heading) |
| Profile download progress dialog | ⚠️ | gauge wider than the screen (cosmetic) |
| Wide combo boxes / long side texts in settings | ⚠️ | page scrolls sideways a little |

## Test environment note
Tests now run on `pstab` (1280x800, DPR 1, made by avdmanager into avd/): ~2.6 GB of host RAM with PrusaSlicer running.
The first AVD (2560x1600 DPR 2) cost ~12 GB (GPU emulation) and crashed the shared build machine; start-emulator.sh stops
the emulator if qemu grows past PS_EMU_MAX_MB.
