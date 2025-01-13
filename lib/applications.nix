{ lib, ... }:
{
  mkCosmicApplication =
    {
      configurationVersion,
      description ? null,
      extraConfig ? _cfg: { },
      extraOptions ? { },
      hasSettings ? true,
      identifier,
      imports ? [ ],
      maintainers,
      name,
      originalName ? name,
      package ? name,
      settingsDescription ? "Configuration entries for ${originalName}.",
      settingsOptions ? { },
      settingsExample ? null,
    }@args:
    let
      loc = [
        "programs"
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
          options.programs.${name} =
            {
              enable = lib.mkEnableOption originalName;
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

          config = lib.mkIf cfg.enable (
            lib.mkMerge [
              {
                assertions = [
                  {
                    assertion = cfg.enable -> config.wayland.desktopManager.cosmic.enable;
                    message = "COSMIC Desktop declarative configuration must be enabled to use ${originalName} module.";
                  }
                ];

                home.packages = lib.optionals (cfg.package != null) [ cfg.package ];
              }

              (lib.optionalAttrs hasSettings {
                wayland.desktopManager.cosmic = {
                  configFile.${identifier} = {
                    entries = cfg.settings;
                    version = configurationVersion;
                  };
                };
              })

              (lib.optionalAttrs (args ? extraConfig) (
                lib.cosmic.modules.applyExtraConfig { inherit cfg extraConfig opts; }
              ))
            ]
          );

          meta = {
            inherit maintainers;
            cosmicInfo = {
              inherit description;
              url = args.url or opts.package.default.meta.homepage;
              path = loc;
            };
          };
        };
    in
    {
      imports = imports ++ [ module ];
    };
}
