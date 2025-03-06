{ lib, ... }:
lib.makeExtensible (self: {
  applets = import ./applets.nix { inherit lib; };
  applications = import ./applications.nix { inherit lib; };
  generators = import ./generators.nix { inherit lib; };
  modules = import ./modules.nix { inherit lib; };
  options = import ./options.nix { inherit lib; };
  utils = import ./utils.nix { inherit lib; };

  inherit (self.generators) fromRON toRON;

  inherit (self.modules) applyExtraConfig;

  inherit (self.options)
    defaultNullOpts
    mkNullOrOption
    mkNullOrOption'
    mkSettingsOption
    ;

  inherit (self.utils)
    cleanNullsExceptOptional
    isRonType
    literalRon
    mkRon
    mkRonExpression
    nestedLiteral
    nestedLiteralRon
    nestedRonExpression
    ronExpression
    rustToNixType
    ;
})
