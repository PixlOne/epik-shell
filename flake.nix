{
  description = "EpikShell - A desktop shell based on Astal";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.astal.follows = "astal";
    };
  };

  outputs =
    inputs @ { self
    , nixpkgs
    , systems
    , astal
    , ags
    , ...
    }:
    let
      name = "epik-shell";
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
        let
          astal = inputs.astal.packages.${system};
        in
        {
          default = pkgs.stdenvNoCC.mkDerivation {
            name = name;
            src = ./.;
            meta.mainProgram = name;

            nativeBuildInputs = with pkgs; [
              wrapGAppsHook3
              gobject-introspection
              ags.packages.${system}.default
            ];

            buildInputs = [
              pkgs.glib
              pkgs.gjs
              pkgs.gtk4
              pkgs.astal.gjs
              astal.io
              astal.astal4
              astal.apps
              astal.battery
              astal.bluetooth
              astal.hyprland
              astal.mpris
              astal.notifd
              astal.network
              astal.powerprofiles
              astal.tray
              astal.wireplumber
              # packages like astal.battery or pkgs.libsoup_4
            ];

            installPhase =
              let
                astal-gjs = "${pkgs.astal.gjs}/share/astal/gjs";
              in
              ''
                mkdir -p $out/bin
                mkdir -p $out/share/${name}
                cp -r $src/styles $out/share/${name}/styles
                ags bundle --gtk 4 --alias "astal=${astal-gjs}" -d "SRC='$out/share/${name}'" app.ts $out/bin/${name}
              '';

            preFixup = ''
              gappsWrapperArgs+=(
                --prefix PATH : ${pkgs.lib.makeBinPath (with pkgs; [
                  dart-sass
                  hyprpicker
                  swappy
                  wf-recorder
                  wayshot
                  slurp
                  wl-clipboard
                  brightnessctl
                ])}
              )
            '';
          };
        }
      );

      homeModules = {
        default = self.homeModules.epik-shell;
        epik-shell =
          { pkgs, ... }: {
            imports = [
              ./nix
              {
                options.epik-shell.package = lib.mkOption
                  {
                    type = lib.types.package;
                    default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
                  };
              }
            ];
          };
      };

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
            ] ++ self.packages.${system}.default.buildInputs
            ++ self.packages.${system}.default.nativeBuildInputs;
          };
        }
      );
    };
}
