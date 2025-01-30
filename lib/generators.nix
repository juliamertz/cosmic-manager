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
        in
        {
          bool = lib.boolToString value;
          float =
            let
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
            trimFloatString value;
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
                assert lib.assertMsg (value ? value) "lib.cosmic.generators.toRON: raw type must have a value.";
                assert lib.assertMsg (builtins.isString value.value)
                  "lib.cosmic.generators.toRON: raw type value must be a string.";

                value.value
              else if value.__type == "optional" then
                assert lib.assertMsg (
                  value ? value
                ) "lib.cosmic.generators.toRON: optional type must have a value.";

                if value.value == null then "None" else "Some(${toRON' startIndent value.value})"
              else if value.__type == "char" then
                assert lib.assertMsg (value ? value) "lib.cosmic.generators.toRON: char type must have a value.";
                assert lib.assertMsg (builtins.isString value.value)
                  "lib.cosmic.generators.toRON: char type value must be a string.";
                assert lib.assertMsg (
                  builtins.stringLength value.value == 1
                ) "lib.cosmic.generators.toRON: char type value must be a single character string.";

                "'${value.value}'"
              else if value.__type == "enum" then
                assert lib.assertMsg (
                  value ? variant
                ) "lib.cosmic.generators.toRON: enum type must have a variant.";
                assert lib.assertMsg (builtins.isString value.variant)
                  "lib.cosmic.generators.toRON: enum type variant must be a string value.";

                if value ? value then
                  assert lib.assertMsg (builtins.isList value.value)
                    "lib.cosmic.generators.toRON: enum type must have a list of values.";

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
                  value.variant
              else if value.__type == "map" then
                assert lib.assertMsg (value ? value) "lib.cosmic.generators.toRON: map type must have a value.";
                assert lib.assertMsg (builtins.isList value.value)
                  "lib.cosmic.generators.toRON: map type value must be a list.";
                assert lib.assertMsg (builtins.all (
                  element: builtins.isAttrs element
                ) value.value) "lib.cosmic.generators.toRON: map type value must be a list of attribute sets.";

                let
                  count = builtins.length value.value;
                in
                if count == 0 then
                  "{}"
                else
                  "{\n${
                    lib.concatImapStringsSep "\n" (
                      index: entry:
                      assert lib.assertMsg (
                        let
                          keys = builtins.attrNames entry;
                        in
                        keys == [
                          "key"
                          "value"
                        ]
                      ) "lib.cosmic.generators.toRON: map type entry must have only 'key' and 'value' attributes.";

                      "${indent nextIndent}${toRON' nextIndent entry.key}: ${toRON' nextIndent entry.value}${
                        lib.optionalString (index != count) ","
                      }"
                    ) value.value
                  },\n${indent startIndent}}"
              else if value.__type == "tuple" then
                assert lib.assertMsg (value ? value) "lib.cosmic.generators.toRON: tuple type must have a value.";
                assert lib.assertMsg (builtins.isList value.value)
                  "lib.cosmic.generators.toRON: tuple type value must be a list.";

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
              else if value.__type == "namedStruct" then
                assert lib.assertMsg (
                  value ? name
                ) "lib.cosmic.generators.toRON: namedStruct type must have a name.";
                assert lib.assertMsg (builtins.isString value.name)
                  "lib.cosmic.generators.toRON: namedStruct type name must be a string.";
                assert lib.assertMsg (
                  value ? value
                ) "lib.cosmic.generators.toRON: namedStruct type must have a value.";
                assert lib.assertMsg (builtins.isAttrs value.value)
                  "lib.cosmic.generators.toRON: namedStruct type value must be a attribute set.";

                let
                  keys = builtins.attrNames value.value;
                  count = builtins.length keys;
                in
                if count == 0 then
                  "${value.name}()"
                else
                  "${value.name}(\n${
                    lib.concatImapStringsSep "\n" (
                      index: key:
                      "${indent nextIndent}${key}: ${toRON' nextIndent value.value.${key}}${
                        lib.optionalString (index != count) ","
                      }"
                    ) keys
                  },\n${indent startIndent})"
              else
                throw "lib.cosmic.generators.toRON: set type ${toString value.__type} is not supported."
            else
              let
                keys = builtins.attrNames value;
                count = builtins.length keys;
              in
              if count == 0 then
                "()"
              else
                "(\n${
                  lib.concatImapStringsSep "\n" (
                    index: key:
                    "${indent nextIndent}${key}: ${toRON' nextIndent value.${key}}${
                      lib.optionalString (index != count) ","
                    }"
                  ) keys
                },\n${indent startIndent})";
          string = lib.strings.escapeNixString value;
        }
        .${type} or (throw "lib.cosmic.generators.toRON: ${type} is not supported.");
    in
    toRON';
}
