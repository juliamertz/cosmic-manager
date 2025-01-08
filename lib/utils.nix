{ lib, ... }:
{
  cleanNullsExceptOptional =
    let
      cleanNullsExceptOptional' =
        attrset:
        lib.filterAttrs (_: value: value != null) (
          builtins.mapAttrs (
            _: value:
            if
              builtins.isAttrs value && !(value ? __type && value.__type == "optional" && value.value == null)
            then
              cleanNullsExceptOptional' value
            else
              value
          ) attrset
        );
    in
    cleanNullsExceptOptional';

  capitalizeWord =
    word:
    with lib.strings;
    concatImapStrings (index: char: if index == 1 then toUpper char else toLower char) (
      stringToCharacters word
    );

  literalRon =
    r:
    let
      raw = lib.cosmic.mkRon "raw" r;
      expression = ''cosmicLib.cosmic.mkRon "raw" ${builtins.toJSON raw.value}'';
    in
    lib.literalExpression expression;

  mkRon =
    type: value:
    {
      char = {
        __type = "char";
        inherit value;
      };
      enum =
        if builtins.isAttrs value then
          if
            builtins.attrNames value == [
              "value"
              "variant"
            ]
          then
            {
              __type = "enum";
              inherit (value) value variant;
            }
          else
            throw "lib.cosmic.ron: enum type must receive a string or an attribute set with value and variant keys value"
        else
          {
            __type = "enum";
            inherit value;
          };
      map = {
        __type = "map";
        inherit value;
      };
      optional = {
        __type = "optional";
        inherit value;
      };
      raw = {
        __type = "raw";
        inherit value;
      };
      tuple = {
        __type = "tuple";
        inherit value;
      };
    }
    .${type} or (throw "lib.cosmic.ron: ${type} is not supported.");

  nestedLiteral = val: {
    __pretty = lib.getAttr "text";
    val = if val._type or null == "literalExpression" then val else lib.literalExpression val;
  };

  nestedLiteralRon = r: with lib.cosmic.utils; nestedLiteral (literalRon r);

  rustToNixType =
    let
      rustToNixType' =
        type:
        let
          handleOption =
            type:
            let
              matches = builtins.match "Option<(.*)>" type;
              innerType = if matches != null then builtins.head matches else null;
            in
            if matches != null then lib.types.ronOptionalOf (rustToNixType' innerType) else null;
          handleVec =
            type:
            let
              matches = builtins.match "Vec<(.*)>" type;
              innerType = if matches != null then builtins.head matches else null;
            in
            if matches != null then lib.types.listOf (rustToNixType' innerType) else null;
          handleArray =
            type:
            let
              matches = builtins.match "[[]([^;]+); *([0-9]+)[]]" type;
              innerType = if matches != null then builtins.head matches else null;
              size = if matches != null then builtins.elemAt matches 1 else null;
            in
            if matches != null then
              lib.types.ronArrayOf (rustToNixType' innerType) (builtins.fromJSON size)
            else
              null;
          handleTuple =
            type:
            let
              innerTypes =
                if (builtins.match "\\((.*?)\\)" type) != null then
                  let
                    inner = builtins.head (builtins.match "\\((.*?)\\)" type);
                    types = map lib.trim (lib.splitString "," inner);
                  in
                  builtins.filter (x: x != "") types
                else
                  null;
            in
            if innerTypes != null then
              if builtins.length innerTypes == 1 then
                lib.types.ronTupleOf (rustToNixType' (builtins.head innerTypes))
              else
                with lib.types; ronTupleOf (oneOf (map rustToNixType' innerTypes))
            else
              null;
          handleMap =
            type:
            let
              hashMapMatches = builtins.match "HashMap<([^,]*),([^>]*)>" type;
              btreeMapMatches = builtins.match "BTreeMap<([^,]*),([^>]*)>" type;

              matches =
                if hashMapMatches != null then
                  hashMapMatches
                else if btreeMapMatches != null then
                  btreeMapMatches
                else
                  null;
              valueType = if matches != null then builtins.head (builtins.tail matches) else null;
            in
            if matches != null then lib.types.ronMapOf (rustToNixType' valueType) else null;
        in
        if handleOption type != null then
          handleOption type
        else if handleVec type != null then
          handleVec type
        else if handleArray type != null then
          handleArray type
        else if handleTuple type != null then
          handleTuple type
        else if handleMap type != null then
          handleMap type
        else
          {
            "&str" = lib.types.str;
            "bool" = lib.types.bool;
            "char" = lib.types.ronChar;
            "f32" = lib.types.float;
            "f64" = lib.types.float;
            "i8" = lib.types.ints.s8;
            "i16" = lib.types.ints.s16;
            "i32" = lib.types.ints.s32;
            "i64" = lib.types.int;
            "i128" = lib.types.int;
            "isize" = lib.types.int;
            "String" = lib.types.str;
            "u8" = lib.types.ints.u8;
            "u16" = lib.types.ints.u16;
            "u32" = lib.types.ints.u32;
            "u64" = lib.types.ints.unsigned;
            "u128" = lib.types.ints.unsigned;
            "usize" = lib.types.ints.unsigned;
          }
          .${lib.trim type} or (throw "Unsupported type: ${type}");
    in
    rustToNixType';
}
