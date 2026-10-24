# PrusaSlicer for Android (unofficial port)

PrusaSlicer 2.9.6 running on Android: the same libslic3r slicing engine and PrusaSlicer's own wxWidgets GUI,
built against wxWidgets-on-Qt for Android. This is the sister project of
[orcaslicer-android](https://github.com/LucasCoraca/orcaslicer-android) and shares its Android wxWidgets port.

Status: work in progress (dependencies and engine build for Android x86_64; GUI port under way).

## How it works
- **Engine**: PrusaSlicer's dependency superbuild cross-compiled with the NDK (`deps/deps-android.cmake` in the patch).
- **GUI toolkit**: wxWidgets 3.3 with the Qt backend, patched for Android (touch, DPI, file picker, WebView over
  `android.webkit.WebView`, Keystore secret store). The patch is shared with the OrcaSlicer port.
- **3D view**: PrusaSlicer's own OpenGL ES 3 renderer (`SLIC3R_OPENGL_ES`); GLEW is replaced by a header shim
  (`android/glew-shim`) because GLES 3 entry points come straight from `libGLESv3`.
- **App**: `android/app` packages `PrusaSlicer.cpp` + the CLI sources as a Qt for Android application; `resources/`
  ships as one zipped asset unpacked on first start.

## Building
Needs: Android SDK with NDK 29.0.14206865 and build-tools 34, JDK 17, Qt 6.8.3 for Android (Widgets, OpenGL,
OpenGLWidgets, PrintSupport) per ABI plus a host Qt, CMake >= 3.28 and Ninja. Paths are set in `env.sh`.

```sh
./fetch-sources.sh                 # PrusaSlicer + wxWidgets at the pinned commits, patches applied
./configure-deps.sh x86_64 && ./run-deps.sh x86_64
./configure-wx.sh x86_64 && ninja -C build/wx-x86_64 install
./configure-app.sh x86_64 && ./build-app.sh x86_64 prusaslicer_make_apk
```
Use `arm64-v8a` instead of `x86_64` for phones.

## License
AGPL-3.0, like PrusaSlicer. PrusaSlicer is a trademark of Prusa Research; this port is not affiliated with or
endorsed by Prusa Research.
