{
  fetchFromGitHub,
  runCommand,
  python3,
}:
let
  cosmic-settings-daemon = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-settings-daemon";
    tag = "epoch-1.0.0-alpha.6";
    hash = "sha256-DtwW6RxHnNh87Xu0NCULfUsHNzYU9tHtFKE9HO3rvME=";
  };
in
runCommand "actions-for-shortcuts.json" { buildInputs = [ python3 ]; } ''
  python3 ${./main.py} ${cosmic-settings-daemon}/config/src/shortcuts/action.rs actions-for-shortcuts.json
  cp actions-for-shortcuts.json $out
''
