{ lib, ... }:
let
  generators = import ./generators.nix { inherit lib; };
in
{
  inherit generators;

  applets = import ./applets.nix { inherit lib; };
  applications = import ./applications.nix { inherit lib; };
  modules = import ./modules.nix { inherit lib; };
  options = import ./options.nix { inherit lib; };
  utils = import ./utils.nix { inherit lib; };

  inherit (generators) ron;
}
