{ lib, ... }:
{
  cleanNullsExceptOptional =
    let
      cleanNullsExceptOptional' =
        attrset:
        lib.filterAttrs (_name: value: value != null) (
          builtins.mapAttrs (
            _name: value:
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
              with lib.types;
              (addCheck (listOf (rustToNixType' innerType)) (x: builtins.length x == (builtins.fromJSON size)))
              // {
                description = "list of ${
                  optionDescriptionPhrase (class: class == "noun" || class == "composite") (rustToNixType' innerType)
                } with a fixed-size of ${size} elements";
              }
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
