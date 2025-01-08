{ lib, ... }:
let
  inherit (lib.cosmic.options) mkNullOrOption';
in
lib.cosmic.applets.mkCosmicApplet {
  name = "audio";
  originalName = "Sound";
  identifier = "com.system76.CosmicAppletAudio";
  configurationVersion = 1;

  maintainers = [ lib.maintainers.HeitorAugustoLN ];

  settingsOptions = {
    show_media_controls_in_top_panel = mkNullOrOption' {
      type = lib.types.bool;
      example = true;
      description = ''
        Whether to show media controls in the top panel.
      '';
    };
  };

  settingsExample = {
    show_media_controls_in_top_panel = true;
  };
}
