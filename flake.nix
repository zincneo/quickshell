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

            # qmlls does not inherit Quickshell's runtime module search path.
            # Expose both Quickshell and Qt modules to the language server.
            QML2_IMPORT_PATH = qmlImportPath;
            QML_IMPORT_PATH = qmlImportPath;
          };
        });
    };
}
