{ lib, pkgs }:
let
  args = pkgs // {
    lib = import ../lib/extend-lib.nix { inherit lib; };

    inherit callTest;
  };

  callTest = lib.callPackageWith args;
in
{
  to-ron = callTest ./to-ron.nix { };
}
