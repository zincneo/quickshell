# Build tasks for the quickshell config.
# Run `just build` to compile the Blobs plugin into ./plugin/Blobs.
# Requires the `just` command; all compilation happens inside `nix develop`.

build_dir := "codes/build"
module_src := build_dir / "qml" / "Blobs"
module_out := "plugin/Blobs"

# Default: list available recipes.
default:
    @just --list

# Build the Blobs plugin and install the minimal runtime files into plugin/Blobs.
build:
    nix develop -c cmake -S codes -B {{build_dir}} -G Ninja -DCMAKE_BUILD_TYPE=Release
    nix develop -c cmake --build {{build_dir}}
    mkdir -p {{module_out}}
    rm -f {{module_out}}/*
    cp {{module_src}}/qmldir {{module_src}}/*.so {{module_src}}/*.qmltypes {{module_out}}/
    @echo "Blobs plugin installed to {{module_out}}"

# Remove all build artifacts and the generated plugin.
clean:
    rm -rf {{build_dir}} plugin/Blobs

# Run the shell locally with the plugin on the import path (dev convenience).
run: build
    QML2_IMPORT_PATH="{{justfile_directory()}}/plugin${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}" quickshell -p shell.qml
