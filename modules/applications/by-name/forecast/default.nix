{ lib, ... }:
lib.cosmic.applications.mkCosmicApplication {
  name = "forecast";
  originalName = "Forecast";
  identifier = "com.jwestall.Forecast";
  configurationVersion = 1;

  maintainers = [ lib.maintainers.HeitorAugustoLN ];

  settingsOptions =
    let
      inherit (lib.cosmic) defaultNullOpts;
    in
    {
      api_key = defaultNullOpts.mkStr "" ''
        The API key for Geocoding API.
      '';

      app_theme =
        defaultNullOpts.mkRonEnum [ "Dark" "Light" "System" ]
          {
            __type = "enum";
            variant = "System";
          }
          ''
            The theme of the application.
          '';

      default_page =
        defaultNullOpts.mkRonEnum [ "DailyView" "Details" "HourlyView" ]
          {
            __type = "enum";
            variant = "HourlyView";
          }
          ''
            The default page of the application.
          '';

      latitude =
        defaultNullOpts.mkRonOptionalOf lib.types.str
          {
            __type = "optional";
            value = "-28.971476";
          }
          ''
            The latitude of the location.
          '';

      location =
        defaultNullOpts.mkRonOptionalOf lib.types.str
          {
            __type = "optional";
            value = "Anta Gorda - RS, Brazil";
          }
          ''
            The name of the location.
          '';

      longitude =
        defaultNullOpts.mkRonOptionalOf lib.types.str
          {
            __type = "optional";
            value = "-412.005691";
          }
          ''
            The longitude of the location.
          '';

      pressure_units =
        defaultNullOpts.mkRonEnum [ "Bar" "Hectopascal" "Kilopascal" "Psi" ]
          {
            __type = "enum";
            variant = "Hectopascal";
          }
          ''
            The units of the pressure.
          '';

      speed_units =
        defaultNullOpts.mkRonEnum [ "KilometresPerHour" "MetersPerSecond" "MilesPerHour" ]
          {
            __type = "enum";
            variant = "KilometresPerHour";
          }
          ''
            The units of the speed.
          '';

      timefmt =
        defaultNullOpts.mkRonEnum [ "TwelveHr" "TwentyFourHr" ]
          {
            __type = "enum";
            variant = "TwelveHr";
          }
          ''
            The time format.
          '';

      units =
        defaultNullOpts.mkRonEnum [ "Celsius" "Fahrenheit" ]
          {
            __type = "enum";
            variant = "Fahrenheit";
          }
          ''
            The units of the temperature.
          '';
    };

  settingsExample = {
    api_key = "";

    app_theme = {
      __type = "enum";
      variant = "System";
    };

    default_page = {
      __type = "enum";
      variant = "HourlyView";
    };

    latitude = {
      __type = "optional";
      value = "-28.971476";
    };

    location = {
      __type = "optional";
      value = "Anta Gorda - RS, Brazil";
    };

    longitude = {
      __type = "optional";
      value = "-412.005691";
    };

    pressure_units = {
      __type = "enum";
      variant = "Hectopascal";
    };

    speed_units = {
      __type = "enum";
      variant = "KilometresPerHour";
    };

    timefmt = {
      __type = "enum";
      variant = "TwelveHr";
    };

    units = {
      __type = "enum";
      variant = "Fahrenheit";
    };
  };
}
