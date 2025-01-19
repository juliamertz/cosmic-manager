{ lib, ... }:
lib.cosmic.applets.mkCosmicApplet {
  name = "panel-button";
  identifier = "com.system76.CosmicPanelButton";
  configurationVersion = 1;
  settingsDescription = "Configuration entries for all panel buttons.";

  maintainers = [ lib.maintainers.HeitorAugustoLN ];

  settingsOptions =
    let
      inherit (lib.cosmic) defaultNullOpts;
    in
    {
      configs =
        let
          configsSubmodule = lib.types.submodule {
            freeformType = with lib.types; attrsOf anything;
            options.force_presentation = lib.mkOption {
              type =
                with lib.types;
                maybeRonRaw (
                  ronOptionalOf (
                    maybeRonRaw (ronEnum [
                      "Icon"
                      "Text"
                    ])
                  )
                );
              example = {
                __type = "optional";
                value = {
                  __type = "enum";
                  variant = "Icon";
                };
              };
              description = ''
                Force the presentation of the buttons on the panel.
              '';
            };
          };
        in
        defaultNullOpts.mkNullable (lib.types.ronMapOf configsSubmodule)
          {
            __type = "map";
            value = [
              {
                key = "Panel";
                value = {
                  force_presentation = {
                    __type = "optional";
                    value = {
                      __type = "enum";
                      variant = "Icon";
                    };
                  };
                };
              }
              {
                key = "Dock";
                value = {
                  force_presentation = {
                    __type = "optional";
                    value = {
                      __type = "enum";
                      variant = "Text";
                    };
                  };
                };
              }
            ];
          }
          ''
            Configurations for the panel buttons.
          '';
    };

  settingsExample = {
    configs = {
      __type = "map";
      value = [
        {
          key = "Panel";
          value = {
            force_presentation = {
              __type = "optional";
              value = {
                __type = "enum";
                variant = "Icon";
              };
            };
          };
        }
        {
          key = "Dock";
          value = {
            force_presentation = {
              __type = "optional";
              value = {
                __type = "enum";
                variant = "Text";
              };
            };
          };
        }
      ];
    };
  };
}
