# Based on: https://github.com/nix-community/nixvim/blob/35d6c12626f9895cd5d8ccf5d19c3d00de394334/modules/misc/nixvim-info.nix
{ lib, ... }:
{
  options.meta.cosmicInfo = lib.mkOption {
    # This will create an attrset of the form:
    #
    # { path.to.plugin.name = <info>; }
    #
    #
    # Where <info> is an attrset of the form:
    # {
    #   file = "path";
    #   description = null or "<DESCRIPTION>";
    #   url = null or "<URL>";
    # }
    type = (with lib.types; nullOr attrs) // {
      merge =
        _: defs:
        builtins.foldl'
          (
            acc: def:
            lib.recursiveUpdate acc (
              lib.setAttrByPath def.value.path {
                inherit (def) file;
                url = def.value.url or null;
                description = def.value.description or null;
              }
            )
          )
          {
            wayland.desktopManager.cosmic.applets = { };
            programs = { };
          }
          defs;
    };
    internal = true;
    default = null;
    description = ''
      cosmic-manager related information for each module.
    '';
  };
}
