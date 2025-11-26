{ config, lib, ... }:
let cfg = config.epik-shell;
in
{
  imports = [
    ./options.nix
  ];

  home.packages = lib.mkIf (cfg.enable) [
    cfg.package
  ];

  home.file.".config/epik-shell/config.json".text = builtins.toJSON cfg.settings;
}
