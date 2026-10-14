cmake_minimum_required(VERSION 3.24)

project(Blobs LANGUAGES CXX)

# Builds the "Blobs" QML module: an SDF "metaball" renderer that smoothly merges
# rounded rectangles so panels appear to grow out of a window border.
#
# The algorithm/shaders are adapted from https://github.com/caelestia-dots/shell
# (GPL-3.0); see codes/Blobs/ for the vendored sources.
#
# The module is built as a shared plugin. Its backing library is emitted into
# the same module directory and the plugin resolves it via an $ORIGIN rpath, so
# the module is relocatable and has no external inter-library .so path
# dependency - only Qt, resolved through the baked (nix store) rpath.
# `just build` then copies the minimal runtime files into ../plugin/Blobs.

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_BUILD_RPATH_USE_ORIGIN ON)

find_package(Qt6 REQUIRED COMPONENTS Core Qml Quick Gui ShaderTools)

qt_standard_project_setup(REQUIRES 6.5)

# Emit the module under <build>/qml/Blobs so that directory can be added to the
# QML import path when running Quickshell.
set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/qml")

qt_add_qml_module(blobs
    URI Blobs
    VERSION 1.0
    SOURCES
        Blobs/blobgroup.cpp
        Blobs/blobgroup.hpp
        Blobs/blobshape.cpp
        Blobs/blobshape.hpp
        Blobs/blobrect.cpp
        Blobs/blobrect.hpp
        Blobs/blobinvertedrect.cpp
        Blobs/blobinvertedrect.hpp
        Blobs/blobmaterial.cpp
        Blobs/blobmaterial.hpp
)

target_link_libraries(blobs PRIVATE Qt6::Core Qt6::Qml Qt6::Quick Qt6::Gui)

# The generated QML type registration includes the headers by bare filename
# (e.g. <blobgroup.hpp>), so expose their directory on the include path.
target_include_directories(blobs PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/Blobs)

# Co-locate the backing library with the plugin and let the plugin find it via
# $ORIGIN, so the whole module directory is self-contained and relocatable.
set_target_properties(blobs PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${QT_QML_OUTPUT_DIRECTORY}/Blobs"
    BUILD_RPATH "$ORIGIN"
    INSTALL_RPATH "$ORIGIN"
)
set_target_properties(blobsplugin PROPERTIES
    BUILD_RPATH "$ORIGIN"
    INSTALL_RPATH "$ORIGIN"
)

qt_add_shaders(blobs "blob_shaders"
    BATCHABLE OPTIMIZED NOHLSL NOMSL
    GLSL "300es,330"
    PREFIX "/"
    BASE "${CMAKE_CURRENT_SOURCE_DIR}/Blobs"
    FILES
        Blobs/shaders/blob.frag
        Blobs/shaders/blob.vert
)
