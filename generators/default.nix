{
  pkgs ?
    let
      lock = (builtins.fromJSON (builtins.readFile ../flake.lock)).nodes.nixpkgs.locked;
      nixpkgs = fetchTarball {
        url =
          assert lock.type == "github";
          "https://github.com/${lock.owner}/${lock.repo}/archive/${lock.rev}.tar.gz";
        sha256 = lock.narHash;
      };
    in
    import nixpkgs { },
  lib ? pkgs.lib,
  ...
}:
lib.fix (self: {
  actions-for-shortcuts = pkgs.callPackage ./actions-for-shortcuts { };
  default = self.generate;
  generate = lib.callPackageWith (pkgs // self) ./generate.nix { };
})
