// GLEW stand-in for Android. PrusaSlicer is built with SLIC3R_OPENGL_ES, so every GL entry point it calls is a
// GLES 3.x core function exported by libGLESv3; no loader is needed. This header keeps the small GLEW API that
// PrusaSlicer touches (glewInit, the extension flags) answering the way a GLES 3 context would.
#pragma once

#include <GLES3/gl32.h>
#include <GLES2/gl2ext.h>

#define GLEW_OK 0
#define GLEW_VERSION 1

#ifdef __cplusplus
inline GLboolean glewExperimental = GL_FALSE;
inline GLenum glewInit() { return GLEW_OK; }
inline const GLubyte *glewGetErrorString(GLenum) { return reinterpret_cast<const GLubyte *>("GLES (no GLEW on Android)"); }
#endif

// framebuffer objects are core in GLES 3
#define GLEW_ARB_framebuffer_object 1
#define GLEW_EXT_framebuffer_object 1
#define GLEW_ARB_compatibility 0
// S3TC is not reliable on mobile GPUs (garbled textures seen on the Orca port); keep textures uncompressed
#define GLEW_EXT_texture_compression_s3tc 0
#define GLEW_EXT_texture_filter_anisotropic 0
#define GLEW_KHR_debug 0
