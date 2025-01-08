{ lib, ... }:
{
  toRON =
    let
      toRON' =
        startIndent: value:
        let
          type = builtins.typeOf value;
          nextIndent = startIndent + 1;

          indent = level: lib.strings.replicate level "    ";
          trimFloatString =
            float:
            let
              string = lib.strings.floatToString float;
            in
            if lib.strings.hasInfix "." string then
              builtins.head (builtins.match "([0-9]+[.][0-9]*[1-9]|[0-9]+[.]0)0*" string)
            else
              string;
        in
        {
          bool = lib.boolToString value;
          float = trimFloatString value;
          int = toString value;
          lambda = throw "Functions are not supported in RON";
          list =
            let
              count = builtins.length value;
            in
            if count == 0 then
              "[]"
            else
              "[\n${
                lib.concatImapStringsSep "\n" (
                  index: element:
                  "${indent nextIndent}${toRON' nextIndent element}${lib.optionalString (index != count) ","}"
                ) value
              },\n${indent startIndent}]";
          null = throw ''
            Null values are cleaned up by lib.cosmic.utils.cleanNullsExceptOptional.
            If you are seeing this message, please report this, as it should not happen.

            If you want to represent a null value in RON, you can use the `optional` type.
          '';
          path = throw "Path is not supported in RON";
          set =
            if value ? __type then
              if value.__type == "raw" then
                if value ? value then
                  if builtins.isString value.value then
                    value.value
                  else
                    throw "lib.cosmic.generators.toRON: raw type value must be a string."
                else
                  throw "lib.cosmic.generators.toRON: raw type must have a value."
              else if value.__type == "optional" then
                if value ? value then
                  if value.value == null then "None" else "Some(${toRON' startIndent value.value})"
                else
                  throw "lib.cosmic.generators.toRON: optional type must have a value."
              else if value.__type == "char" then
                if value ? value then
                  if builtins.isString value.value then
                    if builtins.stringLength value.value == 1 then
                      "'${value.value}'"
                    else
                      throw "lib.cosmic.generators.toRON: char type must be a single character."
                  else
                    throw "lib.cosmic.generators.toRON: char type must be a string value."
                else
                  throw "lib.cosmic.generators.toRON: char type must have a value."
              else if value.__type == "enum" then
                if value ? variant then
                  if value ? value then
                    if builtins.isList value.value then
                      let
                        count = builtins.length value.value;
                      in
                      if count == 0 then
                        "${value.variant}()"
                      else
                        "${value.variant}(\n${
                          lib.concatImapStringsSep "\n" (
                            index: element:
                            "${indent nextIndent}${toRON' nextIndent element}${lib.optionalString (index != count) ","}"
                          ) value.value
                        },\n${indent startIndent})"
                    else
                      throw "lib.cosmic.generators.toRON: enum type must have a list of values."
                  else if builtins.isString value.variant then
                    value.variant
                  else
                    throw "lib.cosmic.generators.toRON: enum type variant must be a string value."
                else
                  throw "lib.cosmic.generators.toRON: enum type must have a variant."
              else if value.__type == "map" then
                if value ? value then
                  if builtins.isList value.value then
                    if builtins.all (x: builtins.isAttrs x) value.value then
                      let
                        count = builtins.length value.value;
                      in
                      if count == 0 then
                        "{}"
                      else
                        "{\n${
                          lib.concatImapStringsSep "\n" (
                            index: entry:
                            let
                              keys = builtins.attrNames entry;
                            in
                            if
                              [
                                "key"
                                "value"
                              ] == keys
                            then
                              "${indent nextIndent}${toRON' nextIndent entry.key}: ${toRON' nextIndent entry.value}${
                                lib.optionalString (index != count) ","
                              }"
                            else
                              throw "lib.cosmic.generators.toRON: map type entry must have only 'key' and 'value' attributes."
                          ) value.value
                        },\n${indent startIndent}}"
                    else
                      throw "lib.cosmic.generators.toRON: map type value must be a list of attribute sets."
                  else
                    throw "lib.cosmic.generators.toRON: map type value must be a list."
                else
                  throw "lib.cosmic.generators.toRON: map type must have a value."
              else if value.__type == "tuple" then
                if value ? value then
                  if builtins.isList value.value then
                    let
                      count = builtins.length value.value;
                    in
                    if count == 0 then
                      "()"
                    else
                      "(\n${
                        lib.concatImapStringsSep "\n" (
                          index: element:
                          "${indent nextIndent}${toRON' nextIndent element}${lib.optionalString (index != count) ","}"
                        ) value.value
                      },\n${indent startIndent})"
                  else
                    throw "lib.cosmic.generators.toRON: tuple type must have a list of values."
                else
                  throw "lib.cosmic.generators.toRON: tuple type must have a value."
              else
                throw "lib.cosmic.generators.toRON: set type ${value.__type} is not supported."
            else
              let
                keys = builtins.attrNames (if value ? __name then value.value else value);
                count = builtins.length keys;
              in
              if count == 0 then
                "()"
              else
                "${lib.optionalString (value ? __name) value.__name}(\n${
                  lib.concatImapStringsSep "\n" (
                    index: key:
                    "${indent nextIndent}${key}: ${
                      toRON' nextIndent (builtins.getAttr key (if value ? __name then value.value else value))
                    }${lib.optionalString (index != count) ","}"
                  ) keys
                },\n${indent startIndent})";
          string = lib.strings.escapeNixString value;
        }
        .${type} or (throw "lib.cosmic.generators.toRON: ${type} is not supported.");
    in
    toRON';

  ron =
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
}
