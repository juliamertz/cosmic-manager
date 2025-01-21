{ lib, ... }:
lib.cosmic.applications.mkCosmicApplication {
  name = "cosmic-edit";
  originalName = "COSMIC Text Editor";
  identifier = "com.system76.CosmicEdit";
  configurationVersion = 1;

  maintainers = [ lib.maintainers.HeitorAugustoLN ];

  settingsOptions =
    let
      inherit (lib.cosmic) defaultNullOpts;
    in
    {
      app_theme =
        defaultNullOpts.mkRonEnum [ "Dark" "Light" "System" ]
          {
            __type = "enum";
            variant = "System";
          }
          ''
            The theme of the application.
          '';

      auto_indent = defaultNullOpts.mkBool true ''
        Whether to automatically indent the code.
      '';

      find_case_sensitive = defaultNullOpts.mkBool false ''
        Whether to make the search case sensitive.
      '';

      find_use_regex = defaultNullOpts.mkBool false ''
        Whether to use regular expressions in the search.
      '';

      find_wrap_around = defaultNullOpts.mkBool true ''
        Whether to wrap around the search.
      '';

      font_name = defaultNullOpts.mkStr "Fira Mono" ''
        The name of the font to be used.
      '';

      font_size = defaultNullOpts.mkU16 14 ''
        The size of the font to be used.
      '';

      highlight_current_line = defaultNullOpts.mkBool true ''
        Whether to highlight the current line.
      '';

      line_numbers = defaultNullOpts.mkBool true ''
        Whether to show line numbers.
      '';

      syntax_theme_dark = defaultNullOpts.mkStr "COSMIC Dark" ''
        The name of the dark syntax theme to be used.
      '';

      syntax_theme_light = defaultNullOpts.mkStr "COSMIC Light" ''
        The name of the light syntax theme to be used.
      '';

      tab_width = defaultNullOpts.mkU16 4 ''
        The width of the tab.
      '';

      vim_bindings = defaultNullOpts.mkBool false ''
        Whether to enable Vim bindings.
      '';

      word_wrap = defaultNullOpts.mkBool true ''
        Whether to wrap the words.
      '';
    };

  settingsExample = {
    app_theme = {
      __type = "enum";
      variant = "System";
    };
    auto_indent = true;
    find_case_sensitive = false;
    find_use_regex = false;
    find_wrap_around = true;
    font_name = "Fira Mono";
    font_size = 16;
    highlight_current_line = true;
    line_numbers = true;
    syntax_theme_dark = "COSMIC Dark";
    syntax_theme_light = "COSMIC Light";
    tab_width = 2;
    vim_bindings = true;
    word_wrap = true;
  };
}
