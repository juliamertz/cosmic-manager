{
  lib,
  rustPlatform,
  cosmic-comp,
}:
rustPlatform.buildRustPackage {
  pname = "cosmic-manager";
  version = "unstable-14-01-2025";
  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./src
      ./Cargo.toml
      ./Cargo.lock
    ];
  };

  cargoHash = "sha256-+YXxaunQIwkdDd1xyqiN4WnDPFWuy0/IiCpYoFpglic=";

  meta = {
    description = "cosmic-manager command-line interface";
    homepage = "https://github.com/HeitorAugustoLN/cosmic-manager";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.HeitorAugustoLN ];
    mainProgram = "cosmic-manager";
    inherit (cosmic-comp.meta) platforms;
  };
}
