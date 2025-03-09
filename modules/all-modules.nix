{ lib, ... }:
let
  inherit (builtins) readDir;
  inherit (lib) foldlAttrs optional;
  inherit (lib.filesystem) listFilesRecursive;

  appletsByName = ./applets/by-name;
  applicationsByName = ./applications/by-name;
  misc = ./misc;
in
[
  ./appearance.nix
  ./compositor.nix
  ./cosmic-manager.nix
  ./files.nix
  ./idle.nix
  ./panels.nix
  ./shortcuts.nix
  ./system-actions.nix
  ./wallpapers.nix
]
++ foldlAttrs (
  prev: name: type:
  prev ++ optional (type == "directory") (applicationsByName + "/${name}")
) [ ] (readDir applicationsByName)
++ lib.foldlAttrs (
  prev: name: type:
  prev ++ optional (type == "directory") (appletsByName + "/${name}")
) [ ] (readDir appletsByName)
++ listFilesRecursive misc
