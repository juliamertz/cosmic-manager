{ lib, ... }:
let
  inherit (lib.cosmic.options) mkNullOrOption;
in
lib.cosmic.applications.mkCosmicApplication {
  name = "cosmic-term";
  originalName = "COSMIC Terminal Emulator";
  package = "cosmic-term";
  identifier = "com.system76.CosmicTerm";
  configurationVersion = 1;

  maintainers = [ lib.maintainers.HeitorAugustoLN ];

  settingsOptions = {
    app_theme = mkNullOrOption {
      type = lib.types.ronEnum [
        "Dark"
        "Light"
        "System"
      ];
      example = {
        __type = "enum";
        variant = "Dark";
      };
      description = ''
        Controls the theme of the terminal.

        - `Dark`: Use the dark theme.
        - `Light`: Use the light theme.
        - `System`: Follows the system theme.
      '';
    };

    bold_font_weight = mkNullOrOption {
      type = lib.types.ints.u16;
      example = 700;
      description = ''
        Specifies the weight of bold text characters in the terminal.
      '';
    };

    dim_font_weight = mkNullOrOption {
      type = lib.types.ints.u16;
      example = 300;
      description = ''
        Specifies the weight of dim text characters in the terminal.
      '';
    };

    focus_follows_mouse = mkNullOrOption {
      type = lib.types.bool;
      example = true;
      description = ''
        Whether to enable focus follows mouse in the terminal.

        When enabled, the terminal split will automatically receive focus
        when the mouse cursor hovers over it, without needing to click.
      '';
    };

    font_name = mkNullOrOption {
      type = lib.types.str;
      example = "JetBrains Mono";
      description = ''
        Specificies the font family to use in the terminal.
      '';
    };

    font_size = mkNullOrOption {
      type = lib.types.ints.u16;
      example = 12;
      description = ''
        Specifies the font size to use in the terminal.
      '';
    };

    font_size_zoom_step_mul_100 = mkNullOrOption {
      type = lib.types.ints.u16;
      example = 100;
      description = ''
        Controls the granularity of font size changes when zooming.

        Value is multiplied by 0.01 to determine the zoom step (e.g. 100 = 1px).
      '';
    };

    font_stretch = mkNullOrOption {
      type = lib.types.ints.u16;
      example = 100;
      description = ''
        Controls the horizontal font spacing of characters in the terminal.
      '';
    };

    font_weight = mkNullOrOption {
      type = lib.types.ints.u16;
      example = 400;
      description = ''
        Specifies the weight of normal text characters in the terminal.
      '';
    };

    opacity = mkNullOrOption {
      type = lib.types.ints.between 0 100;
      example = 100;
      description = ''
        Specifies the opacity of the terminal background.
      '';
    };

    show_headerbar = mkNullOrOption {
      type = lib.types.bool;
      example = true;
      description = ''
        Whether to show the terminal window title bar and menu.
      '';
    };

    syntax_theme_dark = mkNullOrOption {
      type = lib.types.str;
      example = "COSMIC Dark";
      description = ''
        Specifies the color scheme used for syntax highlighting in dark mode.
      '';
    };

    syntax_theme_light = mkNullOrOption {
      type = lib.types.str;
      example = "COSMIC Light";
      description = ''
        Specifies the color scheme used for syntax highlighting in light mode.
      '';
    };

    use_bright_bold = mkNullOrOption {
      type = lib.types.bool;
      example = true;
      description = ''
        Whether the terminal should use bright bold text.
      '';
    };
  };

  settingsExample = {
    app_theme = {
      __type = "enum";
      variant = "Dark";
    };
    bold_font_weight = 700;
    dim_font_weight = 300;
    focus_follows_mouse = true;
    font_name = "JetBrains Mono";
    font_size = 12;
    font_size_zoom_step_mul_100 = 100;
    font_stretch = 100;
    font_weight = 400;
    opacity = 100;
    show_headerbar = true;
    use_bright_bold = true;
  };

  extraOptions = {
    profiles =
      let
        profileSubmodule = lib.types.submodule {
          freeformType = with lib.types; attrsOf cosmicEntryValue;
          options = {
            command = mkNullOrOption {
              type = lib.types.str;
              description = ''
                The shell or program to execute when opening a new terminal instance with this profile.
                If it is not specified, it will default to your system shell.
              '';
              example = "bash";
              apply = toString;
            };
            hold = lib.mkOption {
              type = lib.types.bool;
              description = ''
                Whether the terminal should continue running after the command exits.
              '';
              example = true;
            };
            is_default = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = ''
                Whether the profile is the default.
              '';
              example = true;
            };
            name = lib.mkOption {
              type = lib.types.str;
              description = ''
                The name of the profile.
              '';
              example = "Default";
            };
            syntax_theme_dark = lib.mkOption {
              type = lib.types.str;
              description = ''
                Specifies the color scheme used for syntax highlighting in dark mode for this profile.
              '';
              example = "COSMIC Dark";
            };
            syntax_theme_light = lib.mkOption {
              type = lib.types.str;
              description = ''
                Specifies the color scheme used for syntax highlighting in light mode for this profile.
              '';
              example = "COSMIC Light";
            };
            tab_title = mkNullOrOption {
              type = lib.types.str;
              description = ''
                Overrides the title of the terminal tab.
                If it is not specified, it will not override the title.
              '';
              example = "Default";
              apply = toString;
            };
            working_directory = mkNullOrOption {
              type = lib.types.str;
              description = ''
                The working directory to use when opening a new terminal instance with this profile.
                If it is not specified, it will continue using the current working directory.
              '';
              example = "/home/user";
              apply = toString;
            };
          };
        };
      in
      mkNullOrOption {
        type = with lib.types; listOf profileSubmodule;
        example = [
          {
            command = "bash";
            hold = false;
            is_default = true;
            name = "Default";
            syntax_theme_dark = "COSMIC Dark";
            syntax_theme_light = "COSMIC Light";
            tab_title = "Default";
            working_directory = "/home/user";
          }
          {
            command = "bash";
            hold = false;
            is_default = false;
            name = "New Profile";
            syntax_theme_dark = "Catppuccin Mocha";
            syntax_theme_light = "Catppuccin Latte";
            tab_title = "New Profile";
          }
        ];
        description = ''
          The profiles to use in the terminal.
        '';
        apply =
          profiles:
          let
            defaultProfiles = builtins.filter (profile: profile.is_default) profiles;
          in
          if builtins.length defaultProfiles > 1 then
            throw "Only one profile can be the default."
          else if builtins.length defaultProfiles < 1 then
            throw "At least one profile must be the default."
          else
            profiles;
      };

    colorSchemes =
      let
        colorsSubmodule =
          scope:
          lib.types.submodule {
            freeformType = with lib.types; attrsOf cosmicEntryValue;
            options = {
              black = lib.mkOption {
                type = lib.types.hexColor;
                description = ''
                  The black color of ${scope} colors.
                '';
                example = "#000000";
              };
              blue = lib.mkOption {
                type = lib.types.hexColor;
                description = ''
                  The blue color of ${scope} colors.
                '';
                example = "#0000FF";
              };
              cyan = lib.mkOption {
                type = lib.types.hexColor;
                description = ''
                  The cyan color of ${scope} colors.
                '';
                example = "#00FFFF";
              };
              green = lib.mkOption {
                type = lib.types.hexColor;
                description = ''
                  The green color of ${scope} colors.
                '';
                example = "#00FF00";
              };
              magenta = lib.mkOption {
                type = lib.types.hexColor;
                description = ''
                  The magenta color of ${scope} colors.
                '';
                example = "#FF00FF";
              };
              red = lib.mkOption {
                type = lib.types.hexColor;
                description = ''
                  The red color of ${scope} colors.
                '';
                example = "#FF0000";
              };
              white = lib.mkOption {
                type = lib.types.hexColor;
                description = ''
                  The white color of ${scope} colors.
                '';
                example = "#FFFFFF";
              };
              yellow = lib.mkOption {
                type = lib.types.hexColor;
                description = ''
                  The yellow color of ${scope} colors.
                '';
                example = "#FFFF00";
              };
            };
          };
        colorSchemeSubmodule = lib.types.submodule {
          freeformType = with lib.types; attrsOf cosmicEntryValue;
          options = {
            bright = lib.mkOption {
              type = colorsSubmodule "bright";
              description = ''
                The bright colors of the terminal.
              '';
            };
            bright_foreground = lib.mkOption {
              type = lib.types.hexColor;
              description = ''
                The bright foreground color of the terminal.
              '';
              example = "#FFFFFF";
            };
            cursor = lib.mkOption {
              type = lib.types.hexColor;
              description = ''
                The color of the terminal cursor.
              '';
              example = "#FFFFFF";
            };
            dim = lib.mkOption {
              type = colorsSubmodule "dim";
              description = ''
                The dim colors of the terminal.
              '';
            };
            dim_foreground = lib.mkOption {
              type = lib.types.hexColor;
              description = ''
                The dim foreground color of the terminal.
              '';
              example = "#FFFFFF";
            };
            foreground = lib.mkOption {
              type = lib.types.hexColor;
              description = ''
                The foreground color of the terminal.
              '';
              example = "#FFFFFF";
            };
            mode = lib.mkOption {
              type = lib.types.enum [
                "dark"
                "light"
              ];
              description = ''
                The mode of the colorscheme.
              '';
              example = "dark";
            };
            name = lib.mkOption {
              type = lib.types.str;
              description = ''
                The name of the colorscheme.
              '';
              example = "Catppuccin Mocha";
            };
            normal = lib.mkOption {
              type = colorsSubmodule "normal";
              description = ''
                The normal colors of the terminal.
              '';
            };
          };
        };
      in
      mkNullOrOption {
        type = lib.types.listOf colorSchemeSubmodule;
        example = [
          {
            mode = "dark";
            name = "Catppuccin Mocha";
            foreground = "#CDD6F4";
            cursor = "#F5E0DC";
            bright_foreground = "#CDD6F4";
            dim_foreground = "#6C7086";
            normal = {
              black = "#45475A";
              red = "#F38BA8";
              green = "#A6E3A1";
              yellow = "#F9E2AF";
              blue = "#89B4FA";
              magenta = "#F5C2E7";
              cyan = "#94E2D5";
              white = "#BAC2DE";
            };
            bright = {
              black = "#585B70";
              red = "#F38BA8";
              green = "#A6E3A1";
              yellow = "#F9E2AF";
              blue = "#89B4FA";
              magenta = "#F5C2E7";
              cyan = "#94E2D5";
              white = "#A6ADC8";
            };
            dim = {
              black = "#45475A";
              red = "#F38BA8";
              green = "#A6E3A1";
              yellow = "#F9E2AF";
              blue = "#89B4FA";
              magenta = "#F5C2E7";
              cyan = "#94E2D5";
              white = "#BAC2DE";
            };
          }
        ];
      };
  };

  extraConfig = cfg: {
    wayland.desktopManager.cosmic.configFile."com.system76.CosmicTerm".entries = lib.mkMerge [
      (lib.optionalAttrs (cfg.profiles != null) {
        default_profile = {
          __type = "optional";
          value = lib.lists.findFirstIndex (profile: profile.is_default) null cfg.profiles;
        };
        profiles = {
          __type = "map";
          value = builtins.listToAttrs (
            lib.imap0 (index: profile: {
              name = toString index;
              value = builtins.removeAttrs profile [ "is_default" ];
            }) cfg.profiles
          );
        };
      })

      (lib.optionalAttrs (cfg.colorSchemes != null) (
        let
          colorSchemes = builtins.filter (colorscheme: colorscheme.mode == "dark") cfg.colorSchemes;
          colorSchemesLight = builtins.filter (colorscheme: colorscheme.mode == "light") cfg.colorSchemes;
        in
        {
          color_schemes_dark = {
            __type = "map";
            value = builtins.listToAttrs (
              lib.imap0 (index: colorscheme: {
                name = toString index;
                value = builtins.removeAttrs colorscheme [ "mode" ];
              }) colorSchemes
            );
          };
          color_schemes_light = {
            __type = "map";
            value = builtins.listToAttrs (
              lib.imap0 (index: colorscheme: {
                name = toString index;
                value = builtins.removeAttrs colorscheme [ "mode" ];
              }) colorSchemesLight
            );
          };
        }
      ))
    ];
  };
}
