{
  fetchurl,
  runCommand,
  python3,
}:
let
  actionRs = fetchurl {
    url = "https://github.com/pop-os/cosmic-settings-daemon/blob/61c76a9d060827402eeb9fe92cae73ce159d66e5/config/src/shortcuts/action.rs";
    hash = "sha256-Qv2ACmoAm98GD2nhIXJpERSJdGhl/BxumfQH3EJzh+4=";
  };
in
runCommand "shortcut-actions" { buildInputs = [ python3 ]; } ''
  cp ${actionRs} action.rs
  cp ${./main.py} main.py

  python3 main.py

  mkdir -p $out
  cp shortcut-actions.json $out
''
