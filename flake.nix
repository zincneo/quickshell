{
  description = "Quickshell QML development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          qtQmlPath = "${pkgs.qt6.qtdeclarative}/lib/qt-6/qml";
          quickshellQmlPath = "${pkgs.quickshell}/lib/qt-6/qml";
          qmlImportPath = "${quickshellQmlPath}:${qtQmlPath}";
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.quickshell
              pkgs.qt6.qtdeclarative
            ];

            # Toolchain for building the vendored Caelestia.Blobs QML plugin.
            nativeBuildInputs = [
              pkgs.cmake
              pkgs.ninja
              pkgs.qt6.qtshadertools
            ];
            buildInputs = [
              pkgs.qt6.qtbase
              pkgs.qt6.qtdeclarative
              pkgs.libGL
            ];

            # qmlls does not inherit Quickshell's runtime module search path.
            # Expose Quickshell and Qt modules to the language server.
            QML2_IMPORT_PATH = qmlImportPath;
            QML_IMPORT_PATH = qmlImportPath;

            # Prepend the generated Blobs plugin (plugin/, holding plugin/Blobs)
            # to the import paths so qmlls and manual runs inside the dev shell
            # resolve `import Blobs`. Resolved at shell init to point at the live
            # working tree, not the immutable Nix store copy of the flake.
            shellHook = ''
              _repoRoot="$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"
              _blobs="$_repoRoot/plugin"
              export QML2_IMPORT_PATH="$_blobs:$QML2_IMPORT_PATH"
              export QML_IMPORT_PATH="$_blobs:$QML_IMPORT_PATH"
            '';
          };
        });
    };
}
