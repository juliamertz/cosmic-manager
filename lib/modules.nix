{ lib, ... }:
{
  applyExtraConfig =
    {
      extraConfig,
      cfg,
      opts,
      enabled ?
        cfg.enable or (throw "`enabled` argument was not provided and `cfg.enable` option was found."),
    }:
    let
      maybeApply =
        variable: maybeFunction:
        if builtins.isFunction maybeFunction then maybeFunction variable else maybeFunction;
    in
    lib.pipe extraConfig [
      (maybeApply cfg)
      (maybeApply opts)
      (lib.mkIf enabled)
    ];
}
