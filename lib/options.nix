# Heavily inspired by nixvim
{ lib, ... }:
let
  inherit (lib.cosmic) isRonType nestedLiteralRon nestedRonExpression;

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
in
{
  inherit mkNullOrOption';

  defaultNullOpts =
    let
      processDefaultNullArgs =
        args:
        assert
          args ? default
          -> abort "defaultNullOpts: unexpected argument `default`. Did you mean `pluginDefault`?";
        assert
          args ? defaultText
          -> abort "defaultNullOpts: unexpected argument `defaultText`. Did you mean `pluginDefault`?";
        args // { default = null; };

      mkAttrs' = args: mkNullableWithRaw' (args // { type = lib.types.attrs; });

      mkAttrsOf' =
        { type, ... }@args:
        mkNullableWithRaw' (args // { type = with lib.types; attrsOf (maybeRonRaw type); });

      mkBool' = args: mkNullableWithRaw' (args // { type = lib.types.bool; });

      mkEnum' =
        { variants, ... }@args:
        assert lib.assertMsg (builtins.isList variants) "mkEnum': `variants` must be a list";
        mkNullableWithRaw' (
          builtins.removeAttrs args [ "variants" ] // { type = lib.types.enum variants; }
        );

      mkFloat' = args: mkNullableWithRaw' (args // { type = lib.types.float; });

      mkHexColor' = args: mkNullableWithRaw' (args // { type = lib.types.hexColor; });

      mkI8' = args: mkNullableWithRaw' (args // { type = lib.types.ints.s8; });

      mkI16' = args: mkNullableWithRaw' (args // { type = lib.types.ints.s16; });

      mkI32' = args: mkNullableWithRaw' (args // { type = lib.types.ints.s32; });

      mkInt' = args: mkNullableWithRaw' (args // { type = lib.types.int; });

      mkListOf' =
        { type, ... }@args:
        mkNullableWithRaw' (args // { type = with lib.types; listOf (maybeRonRaw type); });

      mkNullable' =
        args:
        mkNullOrOption' (
          processDefaultNullArgs args
          // lib.optionalAttrs (args ? example && isRonType args.example) {
            example = lib.cosmic.mkRonExpression 0 args.example null;
          }
        );

      mkNullableWithRaw' =
        { type, ... }@args: mkNullable' (args // { type = lib.types.maybeRonRaw type; });

      mkNumber' = args: mkNullableWithRaw' (args // { type = lib.types.number; });

      mkRaw' =
        args:
        mkNullable' (
          args
          // {
            type = lib.types.ronRaw;
          }
          // lib.optionalAttrs (args ? example) {
            example =
              if builtins.isString args.example then
                lib.cosmic.literalRon args.example
              else
                lib.cosmic.mkRonExpression 0 args.example null;
          }
        );

      mkRonArrayOf' =
        { size, type, ... }@args:
        mkNullableWithRaw' (
          builtins.removeAttrs args [ "size" ]
          // {
            type = with lib.types; ronArrayOf (maybeRonRaw type) size;
          }
        );

      mkRonChar' = args: mkNullableWithRaw' (args // { type = lib.types.ronChar; });

      mkRonEnum' =
        { variants, ... }@args:
        assert lib.assertMsg (builtins.isList variants) "mkRonEnum': `variants` must be a list";
        mkNullableWithRaw' (
          builtins.removeAttrs args [ "variants" ] // { type = lib.types.ronEnum variants; }
        );

      mkRonMap' = args: mkNullableWithRaw' (args // { type = lib.types.ronMap; });

      mkRonMapOf' =
        { type, ... }@args:
        mkNullableWithRaw' (args // { type = with lib.types; ronMapOf (maybeRonRaw type); });

      mkRonNamedStruct' = args: mkNullableWithRaw' (args // { type = lib.types.ronNamedStruct; });

      mkRonNamedStructOf' =
        { type, ... }@args:
        mkNullableWithRaw' (args // { type = with lib.types; ronNamedStructOf (maybeRonRaw type); });

      mkRonOptional' = args: mkNullableWithRaw' (args // { type = lib.types.ronOptional; });

      mkRonOptionalOf' =
        { type, ... }@args:
        mkNullableWithRaw' (args // { type = with lib.types; ronOptionalOf (maybeRonRaw type); });

      mkRonTuple' = args: mkNullableWithRaw' (args // { type = lib.types.ronTuple; });

      mkRonTupleEnum' =
        { variants, ... }@args:
        assert lib.assertMsg (builtins.isList variants) "mkRonTupleEnum': `variants` must be a list";
        mkNullableWithRaw' (
          builtins.removeAttrs args [ "variants" ] // { type = lib.types.ronTupleEnum variants; }
        );

      mkRonTupleEnumOf' =
        { type, variants, ... }@args:
        mkNullableWithRaw' (
          builtins.removeAttrs args [ "variants" ]
          // {
            type = with lib.types; ronTupleEnumOf (maybeRonRaw type) variants;
          }
        );

      mkRonTupleOf' =
        { type, ... }@args:
        mkNullableWithRaw' (args // { type = with lib.types; ronTupleOf (maybeRonRaw type); });

      mkPositiveInt' = args: mkNullableWithRaw' (args // { type = lib.types.ints.positive; });

      mkStr' = args: mkNullableWithRaw' (args // { type = lib.types.str; });

      mkU8' = args: mkNullableWithRaw' (args // { type = lib.types.ints.u8; });

      mkU16' = args: mkNullableWithRaw' (args // { type = lib.types.ints.u16; });

      mkU32' = args: mkNullableWithRaw' (args // { type = lib.types.ints.u32; });

      mkUnsignedInt' = args: mkNullableWithRaw' (args // { type = lib.types.ints.unsigned; });
    in
    {
      inherit
        mkAttrs'
        mkAttrsOf'
        mkBool'
        mkEnum'
        mkFloat'
        mkHexColor'
        mkI8'
        mkI16'
        mkI32'
        mkInt'
        mkListOf'
        mkNullable'
        mkNullableWithRaw'
        mkNumber'
        mkRaw'
        mkRonArrayOf'
        mkRonChar'
        mkRonEnum'
        mkRonMap'
        mkRonMapOf'
        mkRonNamedStruct'
        mkRonNamedStructOf'
        mkRonOptional'
        mkRonOptionalOf'
        mkRonTuple'
        mkRonTupleEnum'
        mkRonTupleEnumOf'
        mkRonTupleOf'
        mkPositiveInt'
        mkStr'
        mkU8'
        mkU16'
        mkU32'
        mkUnsignedInt'
        ;

      mkAttrs = example: description: mkAttrs' { inherit description example; };

      mkAttrsOf =
        type: example: description:
        mkAttrsOf' { inherit description example type; };

      mkBool = example: description: mkBool' { inherit description example; };

      mkEnum =
        variants: example: description:
        mkEnum' { inherit description example variants; };

      mkFloat = example: description: mkFloat' { inherit description example; };

      mkHexColor = example: description: mkHexColor' { inherit description example; };

      mkI8 = example: description: mkI8' { inherit description example; };

      mkI16 = example: description: mkI16' { inherit description example; };

      mkI32 = example: description: mkI32' { inherit description example; };

      mkInt = example: description: mkInt' { inherit description example; };

      mkListOf =
        type: example: description:
        mkListOf' { inherit description example type; };

      mkNullable =
        type: example: description:
        mkNullable' { inherit description example type; };

      mkNullableWithRaw =
        type: example: description:
        mkNullableWithRaw' { inherit description example type; };

      mkNumber = example: description: mkNumber' { inherit description example; };

      mkRaw = example: description: mkRaw' { inherit description example; };

      mkRonArrayOf =
        type: size: example: description:
        mkRonArrayOf' {
          inherit
            description
            example
            size
            type
            ;
        };

      mkRonChar = example: description: mkRonChar' { inherit description example; };

      mkRonEnum =
        variants: example: description:
        mkRonEnum' { inherit description example variants; };

      mkRonMap = example: description: mkRonMap' { inherit description example; };

      mkRonMapOf =
        type: example: description:
        mkRonMapOf' { inherit description example type; };

      mkRonNamedStruct = example: description: mkRonNamedStruct' { inherit description example; };

      mkRonNamedStructOf =
        type: example: description:
        mkRonNamedStructOf' { inherit description example type; };

      mkRonOptional = example: description: mkRonOptional' { inherit description example; };

      mkRonOptionalOf =
        type: example: description:
        mkRonOptionalOf' { inherit description example type; };

      mkRonTuple = example: description: mkRonTuple' { inherit description example; };

      mkRonTupleEnum =
        variants: example: description:
        mkRonTupleEnum' { inherit description example variants; };

      mkRonTupleEnumOf =
        type: variants: example: description:
        mkRonTupleEnumOf' {
          inherit
            description
            example
            type
            variants
            ;
        };

      mkRonTupleOf =
        type: example: description:
        mkRonTupleOf' { inherit description example type; };

      mkPositiveInt = example: description: mkPositiveInt' { inherit description example; };

      mkStr = example: description: mkStr' { inherit description example; };

      mkU8 = example: description: mkU8' { inherit description example; };

      mkU16 = example: description: mkU16' { inherit description example; };

      mkU32 = example: description: mkU32' { inherit description example; };

      mkUnsignedInt = example: description: mkUnsignedInt' { inherit description example; };
    };

  mkNullOrOption = type: description: mkNullOrOption' { inherit description type; };

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
            bool = true;
            float = 1.0;
            list = [
              "a"
              "b"
              "c"
            ];
            set = {
              a = "b";
              c = "d";
            };
            optional = nestedRonExpression "optional" 3 "  ";
            raw = nestedLiteralRon "RawValue";
            char = nestedRonExpression "char" "c" "  ";
            map = nestedRonExpression "map" [
              {
                key = "key";
                value = "value";
              }
            ] "  ";
            tuple = nestedRonExpression "tuple" [
              "a"
              1
            ] "  ";
            namedStruct = nestedRonExpression "namedStruct" {
              name = "NamedStruct";
              value = {
                key = "value";
              };
            } "  ";
            enum = nestedRonExpression "enum" "ActiveWorkspace" "  ";
            tupleEnum = nestedRonExpression "enum" {
              variant = "TupleEnum";
              value = [ "foobar" ];
            } "  ";
          }
        else
          example;
      inherit description;
    };
}
