# Heavily inspired by nixvim
{ lib, ... }:
let
  inherit (lib.cosmic.utils) nestedLiteral;
in
{
  mkNullOrOption' =
    {
      type,
      default ? null,
      ...
    }@args:
    lib.mkOption (
      args
      // {
        type = lib.types.nullOr type;
        inherit default;
      }
    );

  mkNullOrOption =
    type: description: lib.cosmic.options.mkNullOrOption' { inherit description type; };

  mkSettingsOption =
    {
      description,
      example ? null,
      options ? { },
    }:
    lib.mkOption {
      type =
        with lib.types;
        submodule {
          freeformType = attrsOf cosmicEntryValue;
          inherit options;
        };
      default = { };
      example =
        if example == null then
          {
            foo = "bar";
            baz = 42;
            optional = nestedLiteral ''cosmicLib.cosmic.ron "optional" 3'';
            raw = nestedLiteral ''cosmicLib.cosmic.ron "raw" "RawValue"'';
            char = nestedLiteral ''cosmicLib.cosmic.ron "char" "c"'';
            map = nestedLiteral ''cosmicLib.cosmic.ron "map" [ { key = "key"; value = "value"; } ]'';
            tuple = nestedLiteral ''cosmicLib.cosmic.ron "tuple" [ "a" 1 ]'';
            namedStruct = {
              __name = "NamedStruct";
              value = {
                key = "value";
              };
            };
            enum = nestedLiteral ''cosmicLib.cosmic.ron "enum" "ActiveWorkspace"'';
            tupleEnum = nestedLiteral ''cosmicLib.cosmic.ron "enum" { variant = "TupleEnum"; value = [ "foobar" ]; }'';
          }
        else
          example;
      inherit description;
    };
}
