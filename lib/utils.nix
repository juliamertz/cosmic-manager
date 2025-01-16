{ lib, ... }:
let
  isRonType =
    v:
    v ? __type
    && (
      v.__type == "char"
      || v.__type == "enum"
      || v.__type == "map"
      || v.__type == "namedStruct"
      || v.__type == "optional"
      || v.__type == "raw"
      || v.__type == "tuple"
    )
    && (v ? value || v ? variant || (v ? name && v ? value) || (v ? value && v ? variant));

  literalRon =
    r:
    let
      raw = lib.cosmic.mkRon "raw" r;
      expression = ''cosmicLib.cosmic.mkRon "raw" ${builtins.toJSON raw.value}'';
    in
    lib.literalExpression expression;

  nestedLiteral = val: {
    __pretty = builtins.getAttr "text";
    val = if val._type or null == "literalExpression" then val else lib.literalExpression val;
  };

  nestedRonExpression =
    type: value: indent:
    nestedLiteral (ronExpression type value indent);

  ronExpression =
    type: value: indent:
    lib.literalExpression ''cosmicLib.cosmic.mkRon "${type}" ${
      lib.generators.toPretty {
        allowPrettyValues = true;
        inherit indent;
      } value
    }'';
in
{
  inherit
    isRonType
    literalRon
    nestedLiteral
    nestedRonExpression
    ronExpression
    ;

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
            variant = value;
          };
      map = {
        __type = "map";
        inherit value;
      };
      namedStruct =
        if builtins.isAttrs value then
          if
            builtins.attrNames value == [
              "name"
              "value"
            ]
          then
            {
              __type = "namedStruct";
              inherit (value) name value;
            }
          else
            throw "lib.cosmic.ron: namedStruct type must receive a attribute set with name and value keys."
        else
          throw "lib.cosmic.ron: namedStruct type must receive an attribute set as value.";
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

  mkRonExpression =
    let
      mkRonExpression' =
        startIndent: value: previousType:
        let
          nextIndent = startIndent + 1;

          indent = level: lib.strings.replicate level "  ";

          toRonExpression =
            type: value:
            let
              v = nestedRonExpression type value (indent startIndent);
            in
            if previousType == null || previousType == "namedStruct" then
              v
            else
              nestedLiteral "(${v.__pretty v.val})";
        in
        if isRonType value then
          if value.__type == "enum" then
            if value ? variant then
              if value ? value then
                if isRonType value.value then
                  toRonExpression "enum" {
                    inherit (value) variant;
                    value = mkRonExpression' startIndent value.value "enum";
                  }
                else
                  toRonExpression "enum" { inherit (value) value variant; }
              else
                toRonExpression "enum" value.variant
            else
              throw "lib.cosmic.mkRonExpression: enum type must have at least a variant key."
          else if value.__type == "namedStruct" then
            if value ? name && value ? value then
              toRonExpression "namedStruct" {
                inherit (value) name;
                value = builtins.mapAttrs (_: v: mkRonExpression' nextIndent v "namedStruct") value.value;
              }
            else
              throw "lib.cosmic.mkRonExpression: namedStruct type must have name and value keys."
          else if isRonType value.value then
            toRonExpression value.__type (mkRonExpression' startIndent value.value value.__type)
          else
            toRonExpression value.__type value.value
        else if builtins.isList value then
          map (v: mkRonExpression' nextIndent v "list") value
        else if builtins.isAttrs value then
          builtins.mapAttrs (_: v: mkRonExpression' nextIndent v null) value
        else
          value;
    in
    mkRonExpression';

  nestedLiteralRon = r: nestedLiteral (literalRon r);

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
