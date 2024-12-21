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
      str
      number
      bool
      (listOf anything)
      (attrsOf anything)
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
    merge = lib.options.mergeEqualOption;
    name = "ronMap";
  };

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
    merge = lib.options.mergeEqualOption;
    name = "ronNamedStruct";
  };

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
    merge = lib.options.mergeEqualOption;
    name = "ronTuple";
  };

  hexColor = lib.types.strMatching "^#?([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$";
}
