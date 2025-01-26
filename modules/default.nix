{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = import ../lib/import-modules.nix {
    inherit config lib pkgs;
    modules = import ./all-modules.nix { inherit lib; };
  };

  options.wayland.desktopManager.cosmic.enable = lib.mkEnableOption "" // {
    description = ''
      Whether to enable declarative configuration management for the COSMIC Desktop environment.

      When enabled, this module allows you to manage your COSMIC Desktop settings through
      `home-manager`.
    '';
  };

  config =
    let
      cfg = config.wayland.desktopManager.cosmic;
    in
    lib.mkIf cfg.enable {
      _module.args.cosmicLib = lib.mkDefault (import ../lib/extend-lib.nix { inherit lib; });
      lib.cosmic = lib.mkDefault config._module.args.cosmicLib.cosmic;
    };
}
