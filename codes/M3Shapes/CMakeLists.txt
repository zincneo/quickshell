cmake_minimum_required(VERSION 3.24)

project(M3Shapes LANGUAGES CXX)

# Builds the "M3Shapes" QML module (Material 3 expressive shapes / MaterialShape).
# Vendored from https://github.com/soramanew/m3shapes.
#
# Same packaging approach as the Blobs plugin: a shared plugin whose backing
# library sits beside it and is resolved via an $ORIGIN rpath, so the emitted
# module (build/qml/M3Shapes) is self-contained (only Qt, via baked rpath).

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_BUILD_RPATH_USE_ORIGIN ON)

find_package(Qt6 REQUIRED COMPONENTS Core Qml Quick Gui ShaderTools)

qt_standard_project_setup(REQUIRES 6.8)

set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/qml")

qt_add_qml_module(m3shapes
    URI M3Shapes
    VERSION 1.0
    SOURCES
        include/m3shapes/core/point.hpp
        include/m3shapes/core/utils.hpp
        include/m3shapes/core/cornerrounding.hpp
        include/m3shapes/core/cubic.hpp
        src/core/cubic.cpp
        include/m3shapes/core/feature.hpp
        src/core/feature.cpp
        include/m3shapes/core/roundedpolygon.hpp
        src/core/roundedpolygon.cpp
        include/m3shapes/morph/floatmapping.hpp
        src/morph/floatmapping.cpp
        include/m3shapes/morph/polygonmeasure.hpp
        src/morph/polygonmeasure.cpp
        include/m3shapes/morph/featuremapping.hpp
        src/morph/featuremapping.cpp
        include/m3shapes/morph/morph.hpp
        src/morph/morph.cpp
        include/m3shapes/shapes/shapes.hpp
        src/shapes/shapes.cpp
        include/m3shapes/shapes/materialshapes.hpp
        src/shapes/materialshapes.cpp
        include/m3shapes/qml/materialshapeitem.hpp
        src/qml/materialshapeitem.cpp
        include/m3shapes/qml/smoothshapematerial.hpp
        src/qml/smoothshapematerial.cpp
)

target_link_libraries(m3shapes PRIVATE Qt6::Core Qt6::Qml Qt6::Quick Qt6::Gui)

# Public <m3shapes/...> includes, plus the qml header dir by basename for the
# generated qmltyperegistration TU (<materialshapeitem.hpp>).
target_include_directories(m3shapes PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/include/m3shapes/qml
)

qt_add_shaders(m3shapes "m3shapes_shaders"
    PREFIX "/m3shapes"
    BASE "${CMAKE_CURRENT_SOURCE_DIR}/src"
    FILES
        src/shaders/smoothshape.vert
        src/shaders/smoothshape.frag
)

# Co-locate the backing library with the plugin; resolve it via $ORIGIN.
set_target_properties(m3shapes PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${QT_QML_OUTPUT_DIRECTORY}/M3Shapes"
    BUILD_RPATH "$ORIGIN"
    INSTALL_RPATH "$ORIGIN"
)
set_target_properties(m3shapesplugin PROPERTIES
    BUILD_RPATH "$ORIGIN"
    INSTALL_RPATH "$ORIGIN"
)
