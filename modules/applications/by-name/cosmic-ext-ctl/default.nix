{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "wayland" "desktopManager" "cosmic" "installCosmicCtl" ]
      [ "programs" "cosmic-ext-ctl" "enable" ]
    )
  ];

  options.programs.cosmic-ext-ctl = {
    enable = lib.mkEnableOption "" // {
      default = true;
      description = ''
        Whether to enable `cosmic-ctl`.

        When disabled, `cosmic-ctl` will not be installed.
        But it will still be used by `cosmic-manager` for managing COSMIC Desktop configurations.
      '';
    };

    package = lib.mkPackageOption pkgs "cosmic-ext-ctl" { };
  };

  config =
    let
      cfg = config.programs.cosmic-ext-ctl;
    in
    lib.mkIf cfg.enable {
      home.packages = [ cfg.package ];
    };
}
