{ lib, ... }:
lib.cosmic.applications.mkCosmicApplication {
  name = "tasks";
  originalName = "Tasks";
  identifier = "dev.edfloreshz.Tasks";
  configurationVersion = 1;

  maintainers = [ lib.maintainers.HeitorAugustoLN ];

  settingsOptions =
    let
      inherit (lib.cosmic) defaultNullOpts;
    in
    {
      app_theme =
        defaultNullOpts.mkRonEnum [ "Dark" "Light" "System" ]
          {
            __type = "enum";
            variant = "System";
          }
          ''
            The theme of the application.
          '';
    };

  settingsExample = {
    app_theme = {
      __type = "enum";
      variant = "System";
    };
  };
}
