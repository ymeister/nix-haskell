{ config, lib, system, ... }:

with lib;

{

  options = {

    "haskell-nix" = {

      nixpkgsSource = mkOption {
        type = types.raw;
        default = config.importing."haskell-nix".sources.nixpkgs-unstable;
        defaultText = literalMD ''
          ```
          config.importing."haskell-nix".sources.nixpkgs-unstable
          ```
        '';
      };

      nixpkgsArgs = mkOption {
        type = types.raw;
        default = config.importing."haskell-nix".nixpkgsArgs;
        defaultText = literalMD ''
          ```
          config.importing."haskell-nix".nixpkgsArgs
          ```
        '';
      };

      nixpkgs = mkOption {
        type = types.raw;
        default = import config."haskell-nix".nixpkgsSource ({ inherit system; } // config."haskell-nix".nixpkgsArgs);
        defaultText = literalMD ''
          ```
          import config."haskell-nix".nixpkgsSource ({ inherit system; } // config."haskell-nix".nixpkgsArgs)
          ```
        '';
      };

      haskell-nix = mkOption {
        type = types.raw;
        default = config."haskell-nix".nixpkgs.haskell-nix;
        defaultText = literalMD ''
          ```
          config."haskell-nix".nixpkgs.haskell-nix
          ```
        '';
      };

      lib = mkOption {
        type = types.raw;
        default = config."haskell-nix".haskell-nix.haskellLib;
        defaultText = literalMD ''
          ```
          config."haskell-nix".haskell-nix.haskellLib
          ```
        '';
      };

      project = mkOption {
        default = {};
        type = types.submodule {
          imports = [
            ({...}@project_args:
              let modules = [
                    (config.thunks."haskell-nix" + "/modules/cabal-project.nix")
                    (config.thunks."haskell-nix" + "/modules/project-common.nix")
                    (config.thunks."haskell-nix" + "/modules/project.nix")
                  ];
                  module_args = project_args // { pkgs = config."haskell-nix".nixpkgs; haskellLib = config."haskell-nix".lib; };
                  options = zipAttrsWith (name: vals: last vals) (map (module: (import module module_args).options) modules);
              in {
                options = recursiveUpdate options {
                  evalPackages.defaultText = literalMD ''
                    ```
                    if pkgs.pkgsBuildBuild.stdenv.system == config.evalSystem
                    then pkgs.pkgsBuildBuild
                    else
                      import pkgs.path {
                        system = config.evalSystem;
                        overlays = pkgs.overlays;
                      };
                    ```
                  '';
                  inputMap.description = ''
                    Specifies the contents of urls in the cabal.project file.
                    The `.rev` attribute is checked against the `tag` for `source-repository-packages`.

                    For `revision` blocks the `inputMap.<url>` will be used and
                    they `.tar.gz` for the `packages` used will also be looked up
                    in the `inputMap`.
                  '';
                };
                config = intersectAttrs options config;
              }
            )
          ];
        };
      };

    };

  };

  config = {

    haskell-nix.project = {
      src = mkForce config.src-driver;
      hsPkgs = null;
    };

  };

}
