{ config, lib, pkgs, ... }:

with lib;

{

  options = {

    name = mkOption {
      type = types.nullOr types.str;
      default = if isPath config.src
        then baseNameOf config.src
        else getName config.src;
      description = ''
        Optional name for better error messages.
      '';
    };

    src = mkOption {
      type = types.either types.path types.package;
      example = "./.";
    };

    compiler-nix-name = mkOption {
      type = types.str;
      description = ''
        The name of the ghc compiler to use.
      '';
      example = "ghc884";
    };

    extraCabalProject = mkOption {
      type = types.listOf types.lines;
      default = [];
      description = ''
        Lines to append to `cabal.project`.
      '';
    };

    extraSrcFiles = mkOption {
      type = types.attrs;
      default = {};
      description = ''
        ExtraSrcFiles to include in the project builds
      '';
    };

    inputMap = mkOption {
      type = types.attrs;
      default = {};
      apply = x: config.source-repository-packages-driver.inputMap // x;
      description = ''
        Specifies the contents of urls in the cabal.project file.
        The `.rev` attribute is checked against the `tag` for `source-repository-packages`.
      '';
      example = literalMD ''
        ```
          inputMap = {
            "{url}/{rev/ref}" = dep_src;
            "https://github.com/obsidiansystems/obelisk-oauth.git/a528c0542e9c30851e7c4542468a053fa5e482ef" = thunkSource ./dep/{thunk};
          };
        ```
      '';
    };

    sha256map = mkOption {
      type = types.nullOr (types.attrsOf (types.either types.str (types.attrsOf types.str)));
      default = null;
      description = ''
        An alternative to adding `--sha256` comments into the cabal.project file.
      '';
      example = literalMD ''
        ```
          sha256map = {
            "url"."rev/ref" = "hash"
            "https://github.com/jgm/pandoc-citeproc"."0.17" = "0dxx8cp2xndpw3jwiawch2dkrkp15mil7pyx7dvd810pwc22pm2q";
            "https://github.com/obsidiansystems/obelisk-oauth.git"."a528c0542e9c30851e7c4542468a053fa5e482ef" = lib.fakeHash;
          };
        ```
      '';
    };

    modules = mkOption {
      readOnly = true;
      type = types.listOf (
        types.submodule {
          imports = [
            ({...}@project_args:
              let modules = [
                    (config.thunks."haskell-nix" + "/modules/cabal.nix")
                    (config.thunks."haskell-nix" + "/modules/component-options.nix")
                    (config.thunks."haskell-nix" + "/modules/hackage.nix")
                    (config.thunks."haskell-nix" + "/modules/package-options.nix")
                    (config.thunks."haskell-nix" + "/modules/plan.nix")
                  ];
                  module_args = project_args // {
                    pkgs = import (config.thunks."haskell-nix" + "/lib/system-pkgs.nix") config."haskell-nix".nixpkgs;
                    pkgconfPkgs = import (config.thunks."haskell-nix" + "/lib/pkgconf-nixpkgs-map.nix") config."haskell-nix".nixpkgs;
                    haskellLib = config."haskell-nix".lib;
                  };
                  options = zipAttrsWith (name: vals: last vals) (map (module: (import module module_args).options) modules);
              in {
                inherit options;
              }
            )
          ];
        }
      );
      default = [];
      apply = x: [
          { packages."${config.name}".components = config.extraSrcFiles; }
        ] ++ x
          ++ config.overrides or []
          ++ config.hackage-driver.package-overlays or []
          ++ config.source-repository-packages-driver.overrides or [];
      description = ''
        `modules` option definitions (readonly). To actually change them use `overrides`.
      '';
    };

    overrides = mkOption {
      type = types.listOf types.unspecified;
      default = [];
      description = ''
        `modules` overrides.
      '';
    };



    shell = mkOption {
      type = types.submodule {
        imports = [
          ({...}@project_args:
            let modules = [
                  (config.thunks."haskell-nix" + "/modules/shell.nix")
                ];
                module_args = project_args // {
                  pkgs = import (config.thunks."haskell-nix" + "/lib/system-pkgs.nix") config."haskell-nix".nixpkgs;
                  pkgconfPkgs = import (config.thunks."haskell-nix" + "/lib/pkgconf-nixpkgs-map.nix") config."haskell-nix".nixpkgs;
                  haskellLib = config."haskell-nix".lib;
                };
                options = zipAttrsWith (name: vals: last vals) (map (module: ((import module { projectConfig = config."haskell-nix".project; }) module_args).options) modules);
            in {
              inherit options;
            }
          )
        ];
      };
    };



    index-state = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Hackage index-state.
      '';
      example = "2019-10-10T00:00:00Z";
    };

    extra-hackage-tarballs = mkOption {
      type = types.nullOr types.attrs;
      default = {};
      apply = x: (if config.hackage-overlays == [] then {} else config.hackage-driver.extra-hackage-tarballs) // x;
    };

    extra-hackages = mkOption {
      type = types.nullOr (types.listOf types.unspecified);
      default = [];
      apply = x: (if config.hackage-overlays == [] then [] else config.hackage-driver.extra-hackages) ++ x;
    };

    pkg-def-extras = mkOption {
      type = types.nullOr (types.listOf types.unspecified);
      default = [];
    };



    src-driver = mkOption {
      type = types.path;
      default = import ../libs/src-driver.nix {
        inherit pkgs;
        src = config.src;
        extraCabalProject =
             config.extraCabalProject or []
          ++ config.source-repository-packages-driver.cabalProject or [];
      };
      defaultText = literalMD ''
      ```
        import ../libs/src-driver.nix {
          inherit pkgs;
          src = config.src;
          extraCabalProject =
               config.extraCabalProject or []
            ++ source-repository-packages-driver.cabalProject or [];
        };
      ```
      '';
      readOnly = true;
    };



    source-repository-packages-driver = mkOption {
      type = types.attrs;
      default = (import ../libs/cabal.nix { inherit pkgs; }).source-repository-packages config.source-repository-packages;
      defaultText = literalMD ''
      ```
      (import ../libs/cabal.nix { inherit pkgs; }).source-repository-packages config.source-repository-packages;
      ```
      '';
      readOnly = true;
    };

    source-repository-packages = mkOption {
      type = types.nullOr (types.listOf (types.either types.path types.attrs));
      default = null;
      example = literalMD ''
        ```
        [
          (deps.obelisk + "/lib/executable-config/inject")
          (deps.obelisk + "/lib/executable-config/lookup")
          (deps.obelisk + "/lib/frontend")
          (deps.obelisk + "/lib/route")
          (deps.obelisk + "/lib/tabulation")
          { src = deps.obelisk + "/lib/asset/manifest"; condition = "!arch(javascript)"; }
          { src = deps.obelisk + "/lib/asset/serve-snap"; condition = "!arch(javascript)"; }
          { src = deps.obelisk + "/lib/backend"; condition = "!arch(javascript)"; }
          { src = deps.obelisk + "/lib/command"; condition = "!arch(javascript)"; }
          { src = deps.obelisk + "/lib/run"; condition = "!arch(javascript)"; }
          { src = deps.obelisk + "/lib/selftest"; condition = "!arch(javascript)"; }
          { src = deps.obelisk + "/lib/snap-extras"; condition = "!arch(javascript)"; }

          (deps.reflex-dom + "/reflex-dom")
          (deps.reflex-dom + "/reflex-dom-core")
          deps.reflex
        ]
        ```
      '';
    };



    hackage-driver = mkOption {
      type = types.attrs;
      default = import ../libs/hackage-driver.nix {
        pkgs = config."haskell-nix".nixpkgs;
        modules = config.hackage-overlays;
      };
      defaultText = literalMD ''
      ```
        import ../libs/hackage-driver.nix {
          pkgs = config."haskell-nix".nixpkgs;
          modules = config.hackage-overlays;
        };
      ```
      '';
      readOnly = true;
    };

    hackage-overlays = mkOption {
      type = types.listOf types.attrs;
      default = [];
      description = ''
        Overlays for hackage, to pass to the cabal solver.

        This will automatically pull and put the defined packages into a "fake" hackage. This allows the cabal solver see packages that can't be conventially added to cabal.project.
        A good example of this is obelisk-generated-static.

        This is a purely helper-code for the nix-side of haskell.nix
      '';
      example = literalMD ''
        ```
        [
          {
            name = "android-activity";
            version = "0.1.1";
            src = pkgs.fetchFromGitHub {
              owner = "obsidiansystems";
              repo = "android-activity";
              rev = "2bc40f6f907b27c66428284ee435b86cad38cff8";
              sha256 = "sha256-AIpbe0JZX68lsQB9mpvR7xAIct/vwQAARVHAK0iChV4=";
            };
          }
        ]
        ```
      '';
    };

  };



  config = {

    shell = {

      tools = {
        cabal = "latest";
      };

      withHaddock = !pkgs.stdenv.hostPlatform.isGhcjs;

    };

  };

}
