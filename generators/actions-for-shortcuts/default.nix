{
  fetchFromGitHub,
  runCommand,
  python3,
}:
let
  cosmic-settings-daemon = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-settings-daemon";
    rev = "refs/tags/epoch-1.0.0-alpha.5";
    hash = "sha256-BCOVyJ1IIik/R4qC/16csJH8yII4WxdxO116hdvUl3I=";
  };
in
runCommand "actions-for-shortcuts.json" { buildInputs = [ python3 ]; } ''
  python3 ${./main.py} ${cosmic-settings-daemon}/config/src/shortcuts/action.rs actions-for-shortcuts.json
  cp actions-for-shortcuts.json $out
''
