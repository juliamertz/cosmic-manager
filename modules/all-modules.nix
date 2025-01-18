{ lib, ... }:
let
  appletsByName = ./applets/by-name;
  appsByName = ./apps/by-name;
  misc = ./misc;
in
[
  ./appearance.nix
  ./files.nix
  ./panels.nix
  ./shortcuts.nix
  ./wallpapers.nix
]
++ lib.foldlAttrs (
  prev: name: type:
  prev ++ lib.optional (type == "directory") (appsByName + "/${name}")
) [ ] (builtins.readDir appsByName)
++ lib.foldlAttrs (
  prev: name: type:
  prev ++ lib.optional (type == "directory") (appletsByName + "/${name}")
) [ ] (builtins.readDir appletsByName)
++ lib.filesystem.listFilesRecursive misc
