{
  pkgs ? import <nixpkgs> { },
  ...
}:
let
  inherit (pkgs) lib;
in
pkgs.mkShell {
  strictDeps = true;

  nativeBuildInputs =
    let
      statix-fix = pkgs.writeShellScriptBin "statix-fix" ''
        for file in "''$@"; do
          ${lib.getExe pkgs.statix} fix "$file"
        done
      '';
    in
    [
      pkgs.deadnix
      pkgs.nixfmt-rfc-style
      statix-fix
    ];
}
