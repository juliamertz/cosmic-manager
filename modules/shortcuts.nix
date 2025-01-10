{ config, lib, ... }:
let
  cfg = config.wayland.desktopManager.cosmic;

  inherit (lib.cosmic.options) mkNullOrOption';
  inherit (lib.cosmic.utils) capitalizeWord rustToNixType;
in
{
  options.wayland.desktopManager.cosmic.shortcuts =
    let
      shortcutSubmodule =
        let
          generatedActions = lib.importJSON ../generated/actions-for-shortcuts.json;

          allActions = generatedActions.Actions;
          actionDependencies = generatedActions.Dependencies;

          actionsWithoutType = builtins.filter (action: !(builtins.hasAttr "type" action)) allActions;
          actionsWithType = builtins.filter (action: builtins.hasAttr "type" action) allActions;
          actionsWithTypeGrouped = builtins.groupBy (action: action.type) actionsWithType;
          actionsWithTypeKeyValue = builtins.mapAttrs (
            _type: actions: map (action: action.name) actions
          ) actionsWithTypeGrouped;

          simpleActions = map (action: action.name) actionsWithoutType;
        in
        lib.types.submodule {
          options = {
            description = mkNullOrOption' {
              type = with lib.types; ronOptionalOf str;
              example = {
                __type = "optional";
                value = "Open Terminal";
              };
              description = ''
                A description for the shortcut.
                Used by COSMIC Settings to display the name of a custom shortcut.
                This field is optional, and should only be used when defining custom shortcuts.
              '';
            };
            key = lib.mkOption {
              type = lib.types.str;
              example = "Super+Q";
              description = ''
                The key combination that triggers the action.
                For example, "Super+Q" would trigger the action when the Super and Q keys are pressed together.
              '';
            };
            action = lib.mkOption {
              type =
                with lib.types;
                oneOf (
                  [
                    (ronEnum simpleActions)
                  ]
                  ++ lib.mapAttrsToList (
                    type: names:
                    let
                      elemType =
                        if builtins.hasAttr type actionDependencies then
                          ronEnum (map (action: action.name) actionDependencies.${type})
                        else
                          rustToNixType type;
                    in
                    ronTupleEnumOf elemType names
                  ) actionsWithTypeKeyValue
                );
              example = {
                __type = "enum";
                variant = "Spawn";
                value = [ "firefox" ];
              };
              description = ''
                The action triggered by the shortcut.
                Actions can include running a command, moving windows, system actions, and more.
              '';
            };
          };
        };
    in
    mkNullOrOption' {
      type = lib.types.listOf shortcutSubmodule;
      example = [
        {
          description = "Open Firefox";
          key = "Super+B";
          action = {
            __type = "enum";
            variant = "Spawn";
            value = [ "firefox" ];
          };
        }
        {
          key = "Super+Q";
          action = {
            __type = "enum";
            variant = "Close";
          };
        }
        {
          key = "Super+M";
          action = {
            __type = "enum";
            variant = "Disable";
          };
        }
        {
          key = "XF86MonBrightnessDown";
          action = {
            __type = "enum";
            variant = "BrightnessDown";
          };
        }
      ];
      description = ''
        Defines a list of custom shortcuts for the COSMIC desktop environment.
        Each shortcut specifies a key combination, the action to be performed, and optionally a description for a custom shortcut.
      '';
    };

  config =
    let
      parseShortcuts =
        key:
        let
          parts = builtins.filter (x: x != "") (lib.splitString "+" key);

          validModifiers = [
            "Alt"
            "Ctrl"
            "Shift"
            "Super"
          ];
        in
        {
          key =
            let
              last = lib.last parts;
            in
            if builtins.stringLength last == 1 then
              lib.toLower last
            else if builtins.elem (capitalizeWord last) validModifiers then
              throw "Key cannot be a modifier"
            else
              last;
          modifiers = map (
            modifier:
            if builtins.elem modifier validModifiers then
              {
                __type = "enum";
                variant = modifier;
              }
            else
              throw "Invalid modifier: ${modifier}. Valid modifiers are: ${builtins.concatStringsSep ", " validModifiers}"
          ) (lib.unique (lib.init parts));
        };
    in
    lib.mkIf (cfg.enable && cfg.shortcuts != null) {
      wayland.desktopManager.cosmic.configFile."com.system76.CosmicSettings.Shortcuts" = {
        entries.custom = {
          __type = "map";
          value = map (shortcut: {
            key = lib.cosmic.utils.cleanNullsExceptOptional (
              parseShortcuts shortcut.key
              // {
                inherit (shortcut) description;
              }
            );
            value = shortcut.action;
          }) cfg.shortcuts;
        };
        version = 1;
      };
    };
}
