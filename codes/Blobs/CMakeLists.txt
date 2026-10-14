cmake_minimum_required(VERSION 3.24)

project(Blobs LANGUAGES CXX)

# Builds the "Blobs" QML module: an SDF "metaball" renderer that smoothly merges
# rounded rectangles so panels appear to grow out of a window border.
#
# The algorithm/shaders are adapted from https://github.com/caelestia-dots/shell
# (GPL-3.0).
#
# Shared plugin whose backing library sits beside it and is resolved via an
# $ORIGIN rpath, so the emitted module (build/qml/Blobs) is self-contained
# (only Qt, via the baked nix-store rpath).

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_BUILD_RPATH_USE_ORIGIN ON)

find_package(Qt6 REQUIRED COMPONENTS Core Qml Quick Gui ShaderTools)

qt_standard_project_setup(REQUIRES 6.5)

set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/qml")

qt_add_qml_module(blobs
    URI Blobs
    VERSION 1.0
    SOURCES
        blobgroup.cpp
        blobgroup.hpp
        blobshape.cpp
        blobshape.hpp
        blobrect.cpp
        blobrect.hpp
        blobinvertedrect.cpp
        blobinvertedrect.hpp
        blobmaterial.cpp
        blobmaterial.hpp
)

target_link_libraries(blobs PRIVATE Qt6::Core Qt6::Qml Qt6::Quick Qt6::Gui)

# Generated QML type registration includes headers by bare filename.
target_include_directories(blobs PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

qt_add_shaders(blobs "blob_shaders"
    BATCHABLE OPTIMIZED NOHLSL NOMSL
    GLSL "300es,330"
    PREFIX "/"
    BASE "${CMAKE_CURRENT_SOURCE_DIR}"
    FILES
        shaders/blob.frag
        shaders/blob.vert
)

# Co-locate the backing library with the plugin; resolve it via $ORIGIN.
set_target_properties(blobs PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${QT_QML_OUTPUT_DIRECTORY}/Blobs"
    BUILD_RPATH "$ORIGIN"
    INSTALL_RPATH "$ORIGIN"
)
set_target_properties(blobsplugin PROPERTIES
    BUILD_RPATH "$ORIGIN"
    INSTALL_RPATH "$ORIGIN"
)
