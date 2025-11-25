{
  description = "EpikShell - A desktop shell based on Astal";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , systems
    , astal
    ,
    }:
    let
      inherit (nixpkgs) lib;
      forEachSystem = f:
        lib.genAttrs (import systems) (
          system:
          (f system) {
            pkgs = import nixpkgs { inherit system; };
          }
        );
    in
    {
      packages = forEachSystem (system:
        { pkgs }:
        {
          default = pkgs.stdenvNoCC.mkDerivation {
            name = "epik-shell";
            src = ./.;

            nativeBuildInputs = [
              pkgs.wrapGAppsHook3
              pkgs.gobject-introspection
              pkgs.esbuild
            ];

            buildInputs = [
              pkgs.gjs
              pkgs.glib
              pkgs.gtk4
              astal.packages.${system}.io
              astal.packages.${system}.astal4
            ];

            installPhase = ''
              mkdir -p $out/bin

              esbuild \
                --bundle src/app.js \
                --outfile=$out/bin/my-shell \
                --format=esm \
                --sourcemap=inline \
                --external:gi://\*
            '';
          };
        }
      );

      devShells = forEachSystem (system:
        { pkgs }:
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              nixd
              cachix
              lorri
              nil
              niv
              nixpkgs-fmt
              statix
              vulnix
              haskellPackages.dhall-nix
            ];
          };
        }
      );
    };
}
