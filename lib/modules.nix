{ lib, ... }:
{
  applyExtraConfig =
    {
      extraConfig,
      cfg,
      enabled ? cfg.enable,
    }:
    let
      maybeApply =
        variable: maybeFunction:
        if builtins.isFunction maybeFunction then maybeFunction variable else maybeFunction;
    in
    lib.pipe extraConfig [
      (maybeApply cfg)
      (lib.mkIf enabled)
    ];
}
