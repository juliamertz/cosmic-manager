{
  lib ? pkgs.lib,
  pkgs,
  ...
}:
lib.fix (
  self:
  let
    call = lib.callPackageWith {
      inherit call pkgs self;
      lib = self.extendedLib;
    };
  in
  {
    generators = call ./generators.nix;
    extendedLib = call ./extend-lib.nix { inherit lib; };
  }
)
