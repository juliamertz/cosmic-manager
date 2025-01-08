{ lib, ... }:
let
  applets = import ./applets.nix { inherit lib; };
  applications = import ./applications.nix { inherit lib; };
  generators = import ./generators.nix { inherit lib; };
  modules = import ./modules.nix { inherit lib; };
  options = import ./options.nix { inherit lib; };
  utils = import ./utils.nix { inherit lib; };
in
{
  inherit
    applets
    applications
    generators
    modules
    options
    utils
    ;

  inherit (generators) toRON;

  inherit (modules) applyExtraConfig;

  inherit (options) mkNullOrOption mkNullOrOption' mkSettingsOption;

  inherit (utils)
    cleanNullsExceptOptional
    capitalizeWord
    literalRon
    mkRon
    nestedLiteral
    nestedLiteralRon
    rustToNixType
    ;
}
