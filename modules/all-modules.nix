{ lib, ... }:
let
  appletsByName = ./applets/by-name;
  applicationsByName = ./applications/by-name;
  misc = ./misc;
in
[
  ./appearance.nix
  ./compositor.nix
  ./files.nix
  ./idle.nix
  ./panels.nix
  ./shortcuts.nix
  ./wallpapers.nix
]
++ lib.foldlAttrs (
  prev: name: type:
  prev ++ lib.optional (type == "directory") (applicationsByName + "/${name}")
) [ ] (builtins.readDir applicationsByName)
++ lib.foldlAttrs (
  prev: name: type:
  prev ++ lib.optional (type == "directory") (appletsByName + "/${name}")
) [ ] (builtins.readDir appletsByName)
++ lib.filesystem.listFilesRecursive misc
