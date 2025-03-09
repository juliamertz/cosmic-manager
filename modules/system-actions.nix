{ config, lib, ... }:
let
  inherit (lib) mkIf types;
  inherit (lib.cosmic) defaultNullOpts;
in
{
  options.wayland.desktopManager.cosmic.systemActions =
    defaultNullOpts.mkRonMapOf types.str
      {
        __type = "map";
        value = [
          {
            key = {
              __type = "enum";
              variant = "Terminal";
            };

            value = "ghostty";
          }
          {
            key = {
              __type = "enum";
              variant = "Launcher";
            };

            value = "krunner";
          }
        ];
      }
      ''
        Overrides for COSMIC Desktop system actions.
      '';

  config =
    let
      cfg = config.wayland.desktopManager.cosmic;
    in
    mkIf (cfg.systemActions != null) {
      wayland.desktopManager.cosmic.configFile."com.system76.CosmicSettings.Shortcuts" = {
        entries.system_actions = cfg.systemActions;
        version = 1;
      };
    };
}
