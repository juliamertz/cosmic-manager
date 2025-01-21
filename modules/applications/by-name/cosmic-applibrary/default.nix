{ lib, ... }:
lib.cosmic.applications.mkCosmicApplication {
  name = "cosmic-applibrary";
  originalName = "COSMIC Application Library";
  identifier = "com.system76.CosmicAppLibrary";
  configurationVersion = 1;

  maintainers = [ lib.maintainers.HeitorAugustoLN ];

  settingsOptions =
    let
      inherit (lib.cosmic) defaultNullOpts;
    in
    {
      groups =
        let
          groupsSubmodule = lib.types.submodule {
            freeformType = with lib.types; attrsOf anything;
            options = {
              filter = lib.mkOption {
                type =
                  let
                    categorySubmodule = lib.types.submodule {
                      freeformType = with lib.types; attrsOf anything;
                      options = {
                        categories = lib.mkOption {
                          type = with lib.types; maybeRonRaw (listOf str);
                          example = [ "Office" ];
                          description = ''
                            The categories of the group.
                          '';
                        };

                        exclude = lib.mkOption {
                          type = with lib.types; maybeRonRaw (listOf str);
                          example = [ "com.system76.CosmicStore" ];
                          description = ''
                            The applications to exclude from the group.
                          '';
                        };

                        include = lib.mkOption {
                          type = with lib.types; maybeRonRaw (listOf str);
                          example = [ "com.system76.CosmicStore" ];
                          description = ''
                            The applications to include in the group.
                          '';
                        };
                      };
                    };
                  in
                  with lib.types;
                  maybeRonRaw (oneOf [
                    (ronEnum [ "None" ])
                    (ronTupleEnumOf (listOf str) [ "AppIds" ] 1)
                    (ronNamedStructOf categorySubmodule)
                  ]);
                example = {
                  __type = "namedStruct";
                  name = "Categories";
                  value = {
                    categories = [ "Office" ];
                    exclude = [ ];
                    include = [
                      "org.gnome.Totem"
                      "org.gnome.eog"
                      "simple-scan"
                      "thunderbird"
                    ];
                  };
                };
                description = ''
                  The filter of the group.
                '';
              };

              icon = lib.mkOption {
                type = with lib.types; maybeRonRaw str;
                example = "folder-symbolic";
                description = ''
                  The icon of the group.
                '';
              };

              name = lib.mkOption {
                type = with lib.types; maybeRonRaw str;
                example = "cosmic-office";
                description = ''
                  The name of the group.
                '';
              };
            };
          };
        in
        defaultNullOpts.mkNullable (lib.types.listOf groupsSubmodule)
          [
            {
              name = "cosmic-office";
              icon = "folder-symbolic";
              filter = {
                __type = "namedStruct";
                name = "Categories";
                value = {
                  categories = [ "Office" ];
                  exclude = [ ];
                  include = [
                    "org.gnome.Totem"
                    "org.gnome.eog"
                    "simple-scan"
                    "thunderbird"
                  ];
                };
              };
            }
            {
              name = "Games";
              icon = "folder-symbolic";
              filter = {
                __type = "enum";
                variant = "AppIds";
                value = [
                  "Counter-Strike 2"
                ];
              };
            }
          ]
          ''
            The groups of applications to display.
          '';
    };

  settingsExample = {
    groups = [
      {
        name = "cosmic-office";
        icon = "folder-symbolic";
        filter = {
          __type = "namedStruct";
          name = "Categories";
          value = {
            categories = [ "Office" ];
            exclude = [ ];
            include = [
              "org.gnome.Totem"
              "org.gnome.eog"
              "simple-scan"
              "thunderbird"
            ];
          };
        };
      }
      {
        name = "Games";
        icon = "folder-symbolic";
        filter = {
          __type = "enum";
          variant = "AppIds";
          value = [
            "Counter-Strike 2"
          ];
        };
      }
    ];
  };
}
