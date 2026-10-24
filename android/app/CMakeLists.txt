# PrusaSlicer for Android: the desktop entry point (PrusaSlicer.cpp + CLI) + the unmodified GUI library, packaged by Qt.
# Included from the top-level CMakeLists.txt when PS_ANDROID_APP is ON (needs the Qt Android toolchain file).
find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets OpenGL OpenGLWidgets PrintSupport)
qt_standard_project_setup()

set(PS_APP_PACKAGE_DIR "${CMAKE_CURRENT_BINARY_DIR}/package")
set(PS_WX_SRC "${CMAKE_SOURCE_DIR}/../third_party/wxWidgets")

# Java bridges of our wxWidgets Android backends + the manifest
file(MAKE_DIRECTORY "${PS_APP_PACKAGE_DIR}/src/org/orcaport/wx" "${PS_APP_PACKAGE_DIR}/assets")
file(GLOB _wx_java "${PS_WX_SRC}/src/qt/android/java/org/orcaport/wx/*.java")
foreach (_f ${_wx_java})
    get_filename_component(_n "${_f}" NAME)
    configure_file("${_f}" "${PS_APP_PACKAGE_DIR}/src/org/orcaport/wx/${_n}" COPYONLY)  # re-configures when the Java changes
endforeach ()
file(GLOB_RECURSE _pkg_res RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}/package" CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/package/res/*")
foreach (_f AndroidManifest.xml build.gradle ${_pkg_res})  # res/: the launcher icon
    configure_file("${CMAKE_CURRENT_SOURCE_DIR}/package/${_f}" "${PS_APP_PACKAGE_DIR}/${_f}" COPYONLY)
endforeach ()

# resources/ -> one asset
find_package(Python3 REQUIRED COMPONENTS Interpreter)
file(GLOB_RECURSE _ps_resource_files CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}/resources/*")
add_custom_command(
    OUTPUT "${PS_APP_PACKAGE_DIR}/assets/resources.zip"
    COMMAND ${Python3_EXECUTABLE} "${CMAKE_CURRENT_SOURCE_DIR}/make_resources_zip.py"
            "${CMAKE_SOURCE_DIR}/resources" "${PS_APP_PACKAGE_DIR}/assets/resources.zip"
    DEPENDS ${_ps_resource_files} "${CMAKE_CURRENT_SOURCE_DIR}/make_resources_zip.py"
    COMMENT "Packing resources/ into resources.zip")
add_custom_target(ps_resources_zip DEPENDS "${PS_APP_PACKAGE_DIR}/assets/resources.zip")

set(_src "${CMAKE_SOURCE_DIR}/src")
qt_add_executable(prusaslicer
    ${_src}/PrusaSlicer.cpp
    ${_src}/CLI/PrintHelp.cpp
    ${_src}/CLI/Setup.cpp
    ${_src}/CLI/LoadPrintData.cpp
    ${_src}/CLI/ProcessTransform.cpp
    ${_src}/CLI/ProcessActions.cpp
    ${_src}/CLI/Run.cpp
    ${_src}/CLI/ProfilesSharingUtils.cpp
    ${_src}/CLI/GuiParams.cpp
    bootstrap.cpp)
add_dependencies(prusaslicer ps_resources_zip)

target_include_directories(prusaslicer PRIVATE ${_src} ${_src}/libslic3r)
target_link_libraries(prusaslicer PRIVATE libslic3r_gui libslic3r libcereal slic3r-arrange-wrapper libseqarrange stb_image miniz
                      Qt6::Widgets Qt6::OpenGLWidgets Qt6::OpenGL Qt6::PrintSupport android log ${CMAKE_DL_LIBS})
target_compile_definitions(prusaslicer PRIVATE wxDEBUG_LEVEL=0)

set_target_properties(prusaslicer PROPERTIES
    QT_ANDROID_PACKAGE_SOURCE_DIR "${PS_APP_PACKAGE_DIR}"
    QT_ANDROID_MIN_SDK_VERSION 28
    QT_ANDROID_TARGET_SDK_VERSION 34
    QT_ANDROID_APP_NAME "PrusaSlicer"
    QT_ANDROID_VERSION_NAME "0.1.0-preview"
    QT_ANDROID_VERSION_CODE 1) # bump for every release, so Android installs it as an update
