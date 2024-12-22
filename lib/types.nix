{ lib, ... }:
{
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
        type = with lib.types; attrsOf cosmicEntryValue;
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
        '';
      };
    };
  };

  cosmicEntryValue =
    with lib.types;
    nullOr (oneOf [
      (attrsOf anything)
      bool
      (listOf anything)
      number
      rawRon
      ronChar
      (ronMapOf anything)
      (ronNamedStructOf anything)
      (ronOptionalOf anything)
      (ronTupleOf anything)
      str
    ]);

  rawRon = lib.mkOptionType {
    check =
      value:
      let
        keys = builtins.attrNames value;
      in
      builtins.isAttrs value
      &&
        [
          "__type"
          "value"
        ] == keys
      && value.__type == "raw"
      && builtins.isString value.value;
    description = "raw RON value";
    descriptionClass = "noun";
    emptyValue = {
      value = {
        __type = "raw";
        value = "";
      };
    };
    merge = lib.options.mergeEqualOption;
    name = "rawRon";
  };

  rawRonEnum =
    let
      rawRonEnum' =
        values:
        let
          name = "rawRonEnum";
          show = v: ''"${v}"'';
        in
        if !builtins.all (value: builtins.isString value) values then
          throw "All values in the enum must be strings."
        else
          lib.mkOptionType {
            check =
              value:
              let
                keys = builtins.attrNames value;
              in
              builtins.isAttrs value
              &&
                [
                  "__type"
                  "value"
                ] == keys
              && value.__type == "raw"
              && builtins.elem value.value values;
            description =
              if values == [ ] then
                "impossible (empty raw RON enum)"
              else if builtins.length values == 1 then
                "raw RON value ${show (builtins.head values)} (singular enum)"
              else
                "one of the following raw RON values: ${lib.concatMapStringsSep ", " show values}";
            descriptionClass = if builtins.length values < 2 then "noun" else "conjunction";
            functor = lib.defaultFunctor name // {
              payload = { inherit values; };
              type = payload: rawRonEnum' payload.values;
              binOp = a: b: { values = lib.unique (a.values + b.values); };
            };
            merge = lib.options.mergeEqualOption;
            inherit name;
          };
    in
    rawRonEnum';

  ronChar = lib.mkOptionType {
    check =
      value:
      let
        keys = builtins.attrNames value;
      in
      builtins.isAttrs value
      &&
        [
          "__type"
          "value"
        ] == keys
      && value.__type == "char"
      && builtins.isString value.value
      && builtins.stringLength value.value == 1;
    description = "RON char";
    descriptionClass = "noun";
    merge = lib.options.mergeEqualOption;
    name = "ronChar";
  };

  ronMap = lib.mkOptionType {
    check =
      value:
      let
        keys = builtins.attrNames value;
      in
      builtins.isAttrs value
      &&
        [
          "__type"
          "value"
        ] == keys
      && value.__type == "map"
      && builtins.isAttrs value.value;
    description = "RON map";
    descriptionClass = "noun";
    emptyValue = {
      value = {
        __type = "map";
        value = { };
      };
    };
    merge = loc: defs: {
      __type = "map";
      value = builtins.foldl' (
        first: def: lib.recursiveUpdate first.value.value def.value.value
      ) (builtins.head defs) (builtins.tail defs);
    };
    name = "ronMap";
  };

  ronMapOf =
    let
      name = "ronMapOf";
      ronMapOf' =
        elemType:
        lib.mkOptionType {
          check =
            value:
            let
              keys = builtins.attrNames value;
            in
            builtins.isAttrs value
            &&
              [
                "__type"
                "value"
              ] == keys
            && value.__type == "map"
            && builtins.isAttrs value.value;
          description = "RON map of ${
            lib.types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
          }";
          descriptionClass = "composite";
          emptyValue = {
            value = {
              __type = "map";
              value = { };
            };
          };
          functor = lib.defaultFunctor name // {
            wrapped = elemType;
          };
          getSubModules = elemType.getSubModules;
          getSubOptions = prefix: elemType.getSubOptions (prefix ++ [ "<name>" ]);
          merge =
            loc: defs:
            let
              pushPositions = map (
                def:
                builtins.mapAttrs (n: v: {
                  inherit (def) file;
                  value = v;
                }) def.value.value
              );
            in
            {
              __type = "map";
              value = builtins.mapAttrs (n: v: v.value) (
                lib.filterAttrs (n: v: v ? value) (
                  lib.zipAttrsWith (
                    name: defs: (lib.mergeDefinitions (loc ++ [ name ]) elemType defs).optionalValue
                  ) (pushPositions defs)
                )
              );
            };
          inherit name;
          nestedTypes.elemType = elemType;
          substSubModules = m: ronMapOf' (elemType.substSubModules m);
        };
    in
    ronMapOf';

  ronNamedStruct = lib.mkOptionType {
    check =
      value:
      let
        keys = builtins.attrNames value;
      in
      builtins.isAttrs value
      &&
        [
          "__name"
          "value"
        ] == keys
      && builtins.isString value.__name
      && builtins.isAttrs value.value;
    description = "RON named struct";
    descriptionClass = "noun";
    merge = loc: defs: {
      __name = builtins.foldl' (
        first: def:
        if def.value.__name != first.value.__name then
          throw "The option '${lib.showOption loc}' has conflicting definition values: ${
            lib.options.showDefs [
              first
              def
            ]
          }\nUse `lib.mkForce value` or `lib.mkDefault value` to change the priority on any of these definitions."
        else
          first.value.__name
      ) (builtins.head defs) (builtins.tail defs);
      value = builtins.foldl' (
        first: def: lib.recursiveUpdate first.value.value def.value.value
      ) (builtins.head defs) (builtins.tail defs);
    };
    name = "ronNamedStruct";
  };

  ronNamedStructOf =
    let
      name = "ronNamedStructOf";
      ronNamedStructOf' =
        elemType:
        lib.mkOptionType {
          check =
            value:
            let
              keys = builtins.attrNames value;
            in
            builtins.isAttrs value
            &&
              [
                "__name"
                "value"
              ] == keys
            && builtins.isString value.__name
            && builtins.isAttrs value.value;
          description = "RON named struct of ${
            lib.types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
          }";
          descriptionClass = "composite";
          functor = lib.defaultFunctor name // {
            wrapped = elemType;
          };
          getSubModules = elemType.getSubModules;
          getSubOptions = prefix: elemType.getSubOptions (prefix ++ [ "<name>" ]);
          merge =
            loc: defs:
            let
              pushPositions = map (
                def:
                builtins.mapAttrs (n: v: {
                  inherit (def) file;
                  value = v;
                }) def.value.value
              );
            in
            {
              __name = builtins.foldl' (
                first: def:
                if def.value.__name != first.value.__name then
                  throw "The option '${lib.showOption loc}' has conflicting definition values: ${
                    lib.options.showDefs [
                      first
                      def
                    ]
                  }\nUse `lib.mkForce value` or `lib.mkDefault value` to change the priority on any of these definitions."
                else
                  first.value.__name
              ) (builtins.head defs) (builtins.tail defs);
              value = builtins.mapAttrs (n: v: v.value) (
                lib.filterAttrs (n: v: v ? value) (
                  lib.zipAttrsWith (
                    name: defs: (lib.mergeDefinitions (loc ++ [ name ]) elemType defs).optionalValue
                  ) (pushPositions defs)
                )
              );
            };
          inherit name;
          nestedTypes.elemType = elemType;
          substSubModules = m: ronNamedStructOf' (elemType.substSubModules m);
        };
    in
    ronNamedStructOf';

  ronOptional = lib.mkOptionType {
    check =
      value:
      let
        keys = builtins.attrNames value;
      in
      builtins.isAttrs value
      &&
        [
          "__type"
          "value"
        ] == keys
      && value.__type == "optional"
      && !builtins.isFunction value.value
      && !builtins.isPath value.value;
    description = "RON optional";
    descriptionClass = "noun";
    merge = lib.options.mergeEqualOption;
    name = "ronOptional";
  };

  ronOptionalOf =
    let
      name = "ronOptionalOf";
      ronOptionalOf' =
        elemType:
        lib.mkOptionType {
          check =
            value:
            let
              keys = builtins.attrNames value;
            in
            builtins.isAttrs value
            &&
              [
                "__type"
                "value"
              ] == keys
            && value.__type == "optional"
            && !builtins.isFunction value.value
            && !builtins.isPath value.value;
          description = "RON optional of ${
            lib.types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
          }";
          descriptionClass = "composite";
          functor = lib.defaultFunctor name // {
            wrapped = elemType;
          };
          getSubModules = elemType.getSubModules;
          getSubOptions = prefix: elemType.getSubOptions (prefix ++ [ "<name>" ]);
          merge = loc: defs: {
            __type = "optional";
            value =
              (lib.mergeDefinitions loc (lib.types.nullOr elemType) (
                map (def: {
                  inherit (def) file;
                  inherit (def.value) value;
                }) defs
              )).mergedValue;
          };
          inherit name;
          nestedTypes.elemType = elemType;
          substSubModules = m: ronOptionalOf' (elemType.substSubModules m);
        };
    in
    ronOptionalOf';

  ronTuple = lib.mkOptionType {
    check =
      value:
      let
        keys = builtins.attrNames value;
      in
      builtins.isAttrs value
      &&
        [
          "__type"
          "value"
        ] == keys
      && value.__type == "tuple"
      && builtins.isList value.value;
    description = "RON tuple";
    descriptionClass = "noun";
    emptyValue = {
      value = {
        __type = "tuple";
        value = [ ];
      };
    };
    merge = loc: defs: {
      __type = "tuple";
      value = builtins.concatLists (map (x: x.value.value) defs);
    };
    name = "ronTuple";
  };

  ronTupleOf =
    let
      name = "ronTupleOf";
      ronTupleOf' =
        elemType:
        lib.mkOptionType {
          check =
            value:
            let
              keys = builtins.attrNames value;
            in
            builtins.isAttrs value
            &&
              [
                "__type"
                "value"
              ] == keys
            && value.__type == "tuple"
            && builtins.isList value.value;
          description = "RON tuple of ${
            lib.types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
          }";
          descriptionClass = "composite";
          emptyValue = {
            value = {
              __type = "tuple";
              value = [ ];
            };
          };
          functor = lib.defaultFunctor name // {
            wrapped = elemType;
          };
          getSubModules = elemType.getSubModules;
          getSubOptions = prefix: elemType.getSubOptions (prefix ++ [ "*" ]);
          merge = loc: defs: {
            __type = "tuple";
            value = map (x: x.value) (
              builtins.filter (x: x ? value) (
                builtins.concatLists (
                  lib.imap1 (
                    n: def:
                    lib.imap1 (
                      m: def':
                      (lib.mergeDefinitions (loc ++ [ "[definition ${toString n}-entry ${toString m}]" ]) elemType [
                        {
                          inherit (def) file;
                          value = def';
                        }
                      ]).optionalValue
                    ) def.value.value
                  ) defs
                )
              )
            );
          };
          inherit name;
          nestedTypes.elemType = elemType;
          substSubModules = m: ronTupleOf' (elemType.substSubModules m);
        };
    in
    ronTupleOf';

  hexColor = lib.types.strMatching "^#?([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$";
}
