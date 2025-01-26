{ lib, ... }:
lib.extend (
  final: prev: {
    cosmic = import ./. { lib = final; };
    types = prev.types // import ./types.nix { lib = final; };
  }
)
