{ lib, ... }:
{
  cosmicEntryValue =
    with lib.types;
    nullOr (oneOf [
      str
      number
      bool
      (listOf anything)
      (attrsOf anything)
    ]);

  cosmicEntry = lib.types.submodule (
    { config, ... }:
    {
      options = {
        value = lib.mkOption {
          type = lib.types.cosmicEntryValue;
          example = true;
          description = ''
            The value stored in the entry.
          '';
        };
        __type = lib.mkOption {
          type =
            with lib.types;
            nullOr (enum [
              "raw"
              "option"
              "char"
              "map"
              "tuple"
            ]);
          default = null;
          example = "raw";
          description = ''
            Internal type classification for cosmic entries.

            When `null`, the entry is treated as a simple value.

            Must not be used together with `__name`.

            The following types are supported:
              - `raw`: The value is stored as-is.
              - `option`: The value is stored as an optional value. (e.g. `Some(value)` or `None`).
              - `char`: The value is stored as a single character. (e.g. `'a'`).
              - `map`: The value is stored as a map. (e.g. `{ "key" = "value"; }`).
              - `tuple`: The value is stored as a tuple. (e.g. `(1, 2, 3)`).
          '';
        };
        __name = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;
          example = "Config";
          description = ''
            Identifier for named struct entries.

            When set, provides a label for the entry in structured data.

            Must not be used together with `__type`.
          '';
        };
      };

      config = {
        _module.check = lib.mkIf (config.__type != null && config.__name != null) (
          throw "Cannot specify both type and name in cosmicEntry"
        );
      };
    }
  );

  coercedCosmicEntry =
    with lib.types;
    coercedTo cosmicEntryValue (value: { inherit value; }) cosmicEntry;

  cosmicComponent = lib.types.submodule {
    options = {
      version = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 1;
        example = 2;
        description = ''
          Schema version number for the component configuration.
        '';
      };

      entries = lib.mkOption {
        type = with lib.types; attrsOf coercedCosmicEntry;
        default = { };
        example = {
          autotile = true;
          autotile_behavior = {
            __type = "raw";
            value = "PerWorkspace";
          };
        };
        description = ''
          Configuration entries for the component.

          Each entry can be either a direct value or a structured entry.
          Direct values are automatically coerced to structured entries.
        '';
      };
    };
  };
}
