{ lib, nixosOptionsDoc }:
{
  version,
  modules ? [ moduleRoot ],
  moduleRoot,
}:
let
  baseDeclarationUrl = "https://github.com/HeitorAugustoLN/cosmic-manager/blob/main";
  declarationIsOurs = declaration: lib.hasPrefix (toString moduleRoot) (toString declaration);
  declarationSubpath = declaration: lib.removePrefix (toString ../. + "/") (toString declaration);

  toGithubDeclaration =
    declaration:
    let
      subpath = declarationSubpath declaration;
    in
    {
      url = "${baseDeclarationUrl}/${subpath}";
      name = "<cosmic-manager/${subpath}>";
    };

  evaluatedModules = lib.evalModules {
    modules = modules ++ [
      {
        options.system.nixos.release = lib.mkOption {
          type = lib.types.str;
          default = lib.trivial.release;
          readOnly = true;
        };

        config = {
          _module.check = false;
        };
      }
    ];
  };

  optionsDoc = nixosOptionsDoc {
    options = builtins.removeAttrs evaluatedModules.options [
      "_module"
      "system"
    ];

    transformOptions =
      option:
      option
      // {
        declarations = map (
          declaration: if declarationIsOurs declaration then toGithubDeclaration declaration else declaration
        ) option.declarations;
      };

    documentType = "none";
    revision = version;
    warningsAreErrors = false;
  };
in
optionsDoc.optionsCommonMark
