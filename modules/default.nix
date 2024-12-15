{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = import ../lib/import-modules.nix {
    inherit
      config
      lib
      pkgs
      ;
    modules = [
      ./files.nix
    ];
  };

  options.wayland.desktopManager.cosmic.enable = lib.mkEnableOption "COSMIC Desktop declarative configuration";
}
