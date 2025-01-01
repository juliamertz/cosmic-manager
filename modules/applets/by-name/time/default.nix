{ lib, ... }:
let
  inherit (lib.cosmic.options) mkNullOrOption;
in
lib.cosmic.applets.mkCosmicApplet {
  name = "time";
  originalName = "Date, Time & Calendar";
  identifier = "com.system76.CosmicAppletTime";
  configurationVersion = 1;

  maintainers = [ lib.maintainers.HeitorAugustoLN ];

  settingsOptions = {
    first_day_of_week = mkNullOrOption {
      type = lib.types.ints.u8;
      example = 6;
      description = ''
        Which day of the week should be considered the first day.

        `0` for Monday, `1` for Tuesday, and so on.
      '';
    };

    military_time = mkNullOrOption {
      type = lib.types.bool;
      example = false;
      description = ''
        Whether to use the 24-hour format for the clock.
      '';
    };

    show_date_in_top_panel = mkNullOrOption {
      type = lib.types.bool;
      example = true;
      description = ''
        Whether to show the current date in the top panel.
      '';
    };

    show_seconds = mkNullOrOption {
      type = lib.types.bool;
      example = false;
      description = ''
        Whether to show the seconds in the clock.
      '';
    };

    show_weekday = mkNullOrOption {
      type = lib.types.bool;
      example = true;
      description = ''
        Whether to show the current weekday in the clock.
      '';
    };
  };

  settingsExample = {
    first_day_of_week = 6;
    military_time = false;
    show_date_in_top_panel = true;
    show_seconds = false;
    show_weekday = true;
  };
}
