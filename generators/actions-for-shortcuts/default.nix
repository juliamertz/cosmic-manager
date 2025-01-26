{
  fetchFromGitHub,
  runCommand,
  python3,
}:
let
  cosmic-settings-daemon = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-settings-daemon";
    tag = "epoch-1.0.0-alpha.5.1";
    hash = "sha256-MlBnwbszwJCa/FQNihSKsy7Bllw807C8qQL9ziYS3fE=";
  };
in
runCommand "actions-for-shortcuts.json" { buildInputs = [ python3 ]; } ''
  python3 ${./main.py} ${cosmic-settings-daemon}/config/src/shortcuts/action.rs actions-for-shortcuts.json
  cp actions-for-shortcuts.json $out
''
