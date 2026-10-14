# Build tasks for the quickshell config.
# Run `just build` to compile every plugin under codes/ into ./plugin/<Name>.
# Requires the `just` command; all compilation happens inside `nix develop`.

# Plugins to build: each is codes/<Name>/CMakeLists.txt -> plugin/<Name>.
modules := "Blobs M3Shapes"

# Default: list available recipes.
default:
    @just --list

# Build all plugins and install the minimal runtime files into plugin/<Name>.
build:
    #!/usr/bin/env bash
    set -euo pipefail
    for m in {{modules}}; do
        echo ">> building $m"
        nix develop -c cmake -S "codes/$m" -B "codes/$m/build" -G Ninja -DCMAKE_BUILD_TYPE=Release
        nix develop -c cmake --build "codes/$m/build"
        mkdir -p "plugin/$m"
        rm -f "plugin/$m"/*
        cp "codes/$m/build/qml/$m/qmldir" "codes/$m/build/qml/$m"/*.so "codes/$m/build/qml/$m"/*.qmltypes "plugin/$m/"
        echo ">> installed plugin/$m"
    done

# Remove all build artifacts and the generated plugins.
clean:
    #!/usr/bin/env bash
    set -euo pipefail
    for m in {{modules}}; do
        rm -rf "codes/$m/build" "plugin/$m"
    done

# Run the shell locally with the plugins on the import path (dev convenience).
run: build
    QML2_IMPORT_PATH="{{justfile_directory()}}/plugin${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}" quickshell -p shell.qml
