{ lib, ... }:
lib.cosmic.applications.mkCosmicApplication {
  name = "cosmic-term";
  originalName = "COSMIC Terminal Emulator";
  package = "cosmic-term";
  identifier = "com.system76.CosmicTerm";
  configurationVersion = 1;

  maintainers = [ lib.maintainers.HeitorAugustoLN ];
}
