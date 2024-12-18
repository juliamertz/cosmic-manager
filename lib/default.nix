{ lib, ... }:
{
  applications = import ./applications.nix { inherit lib; };
  generators = import ./generators.nix { inherit lib; };
  modules = import ./modules.nix { inherit lib; };
  options = import ./options.nix { inherit lib; };
}
