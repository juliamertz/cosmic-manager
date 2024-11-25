{
  lib,
  rustPlatform,
  cosmic-comp,
}:
rustPlatform.buildRustPackage {
  pname = "cosmic2nix";
  version = "1.0.0";

  src = builtins.path {
    name = "cosmic2nix-source";
    path = ./.;
  };

  cargoHash = "sha256-B8rVNeaIC5sJFADAk0FgrAkADoIXAPQ2fhOaPmvfJOM=";

  meta = {
    description = "Convert any COSMIC desktop configurations to cosmic-manager";
    homepage = "https://github.com/HeitorAugustoLN/cosmic-manager";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ HeitorAugustoLN ];
    mainProgram = "cosmic2nix";
    inherit (cosmic-comp.meta) platforms;
  };
}
