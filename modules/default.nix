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

  options.wayland.desktopManager.cosmic = {
    enable = lib.mkEnableOption "" // {
      description = ''
        Whether to enable declarative configuration management for the COSMIC Desktop environment.

        When enabled, this module allows you to manage your COSMIC Desktop settings through
        `home-manager`.
      '';
    };

    installCosmicCtl = lib.mkEnableOption "" // {
      default = true;
      description = ''
        Whether to install `cosmic-ctl`.

        When disabled, `cosmic-ctl` will not be installed.
        But it will still be used by `cosmic-manager` for managing COSMIC Desktop configurations.
      '';
    };

    installCli = lib.mkEnableOption "" // {
      default = true;
      description = ''
        Whether to install `cosmic-manager` command-line interface.
      '';
    };
  };

  config =
    let
      cfg = config.wayland.desktopManager.cosmic;

      cosmic-manager-cli = pkgs.callPackage ../cosmic-manager { };
    in
    lib.mkIf cfg.enable {
      _module.args.cosmicLib = lib.mkDefault (import ../lib/extend-lib.nix { inherit lib; });
      lib.cosmic = lib.mkDefault config._module.args.cosmicLib.cosmic;

      home.packages =
        lib.optionals cfg.installCosmicCtl [ pkgs.cosmic-ext-ctl ]
        ++ lib.optionals cfg.installCli [ cosmic-manager-cli ];
    };
}
