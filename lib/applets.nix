{ lib, ... }:
{
  mkCosmicApplet =
    {
      configurationVersion,
      description ? null,
      extraConfig ? _cfg: { },
      extraOptions ? { },
      hasSettings ? true,
      identifier,
      imports ? [ ],
      isBuiltin ? true,
      maintainers,
      name,
      originalName ? name,
      package ? if isBuiltin then null else name,
      settingsDescription ? "Configuration entries for ${originalName} applet.",
      settingsOptions ? { },
      settingsExample ? null,
    }@args:
    let
      loc = [
        "wayland"
        "desktopManager"
        "cosmic"
        "applets"
        name
      ];

      module =
        {
          config,
          options,
          pkgs,
          ...
        }:
        let
          cfg = lib.getAttrFromPath loc config;
          opts = lib.getAttrFromPath loc options;
        in
        {
          options.wayland.desktopManager.cosmic.applets.${name} =
            lib.optionalAttrs (!isBuiltin) {
              enable = lib.mkEnableOption "${originalName} applet";
              package = lib.mkPackageOption pkgs package {
                extraDescription = "Set to `null` if you don't want to install the package.";
                nullable = true;
              };
            }
            // lib.optionalAttrs hasSettings {
              settings = lib.cosmic.options.mkSettingsOption {
                description = settingsDescription;
                example = settingsExample;
                options = settingsOptions;
              };
            }
            // extraOptions;

          config =
            let
              anySettingsSet =
                (lib.pipe cfg.settings [
                  builtins.attrValues
                  (builtins.filter (x: x != null))
                  builtins.length
                ]) > 0;
              enabled = if isBuiltin then anySettingsSet else cfg.enable;
            in
            assert lib.assertMsg (
              isBuiltin -> hasSettings
            ) "Applet module must have settings if it is a built-in applet.";
            lib.mkIf enabled (
              lib.mkMerge [
                {
                  assertions = [
                    {
                      assertion = enabled -> config.wayland.desktopManager.cosmic.enable;
                      message = "COSMIC Desktop declarative configuration must be enabled to use ${originalName} applet module.";
                    }
                  ];
                }

                (lib.optionalAttrs (!isBuiltin) {
                  home.packages = lib.optionals (cfg.package != null) [ cfg.package ];
                })

                (lib.optionalAttrs hasSettings {
                  wayland.desktopManager.cosmic = {
                    configFile.${identifier} = {
                      entries = cfg.settings;
                      version = configurationVersion;
                    };
                  };
                })

                (lib.optionalAttrs (args ? extraConfig) (
                  lib.cosmic.modules.applyExtraConfig {
                    inherit
                      cfg
                      enabled
                      extraConfig
                      opts
                      ;
                  }
                ))
              ]
            );

          meta = {
            inherit maintainers;
            cosmicInfo = {
              inherit description;
              url =
                if isBuiltin then
                  "https://github.com/pop-os/cosmic-applets"
                else
                  args.url or opts.package.default.meta.homepage;
              path = loc;
            };
          };
        };
    in
    {
      imports = imports ++ [ module ];
    };
}
