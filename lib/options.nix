# Heavily inspired by nixvim
{ lib, ... }:
let
  inherit (lib.cosmic) nestedLiteral nestedLiteralRon;
in
{
  mkNullOrOption =
    type: description: lib.cosmic.options.mkNullOrOption' { inherit description type; };

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
            optional = nestedLiteral ''cosmicLib.cosmic.mkRon "optional" 3'';
            raw = nestedLiteralRon "RawValue";
            char = nestedLiteral ''cosmicLib.cosmic.mkRon "char" "c"'';
            map = nestedLiteral ''cosmicLib.cosmic.mkRon "map" [ { key = "key"; value = "value"; } ]'';
            tuple = nestedLiteral ''cosmicLib.cosmic.mkRon "tuple" [ "a" 1 ]'';
            namedStruct = {
              __name = "NamedStruct";
              value = {
                key = "value";
              };
            };
            enum = nestedLiteral ''cosmicLib.cosmic.mkRon "enum" "ActiveWorkspace"'';
            tupleEnum = nestedLiteral ''cosmicLib.cosmic.mkRon "enum" { variant = "TupleEnum"; value = [ "foobar" ]; }'';
          }
        else
          example;
      inherit description;
    };
}
