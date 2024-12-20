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
}
