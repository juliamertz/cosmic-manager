{
  pkgs ? import <nixpkgs> { },
  ...
}:
pkgs.mkShell {
  strictDeps = true;

  nativeBuildInputs = [ pkgs.nixfmt-rfc-style ];
}
