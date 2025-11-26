{ pkgs, lib, ... }:
with lib;
let epikTypes = (import ./types.nix) { inherit lib; };
in
{
  options.epik-shell = {
    enable = mkEnableOption "EpikShell";
    settings = {
      dock = {
        position = mkOption {
          type = epikTypes.direction.vertical;
          default = "bottom";
        };
        pinned = mkOption {
          type = types.listOf epikTypes.modules;
          default = [ ];
        };
      };

      bar =
        let
          mkSection = default: mkOption {
            type = types.listOf types.str;
            default = default;
          };
        in
        {
          position = mkOption {
            type = epikTypes.direction.vertical;
            default = "top";
          };
          separator = mkOption {
            type = types.bool;
            default = true;
          };
          start = mkSection [ "launcher" "workspace" ];
          center = mkSection [ "time" "notification" ];
          end = mkSection [ "network_speed" "quicksetting" ];
        };

      desktop_clock = {
        position = mkOption {
          type = epikTypes.direction.all;
          default = "top_left";
        };
      };

      theme =
        let
          colorOption = default: mkOption {
            type = types.str;
            default = default;
          };
          themeOf = defaults: mapAttrs (_name: value: colorOption value) defaults;
        in
        {
          font = {
            family = mkOption {
              type = types.nullOr types.str;
              default = null;
            };
            size = mkOption {
              type = types.nullOr types.str;
              default = null;
            };
            weight = mkOption {
              type = types.nullOr types.int;
              default = null;
            };
          };
          mode = mkOption {
            type = epikTypes.theme-mode;
            default = null;
          };
          # TODO: support themeing the rest of this?
          light = themeOf {
            bg = "#fbf1c7";
            fg = "#3c3836";
            accent = "#3c3836";
            red = "#cc241d";
          };
          dark = themeOf {
            bg = "#282828";
            fg = "#ebdbb2";
            accent = "#ebdbb2";
            red = "#cc241d";
          };
        };
    };
  };
}
