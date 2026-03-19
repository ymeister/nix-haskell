{ config, lib, system, pkgs, ... }:

with lib;

# TODO: Remove once nix-thunk and reflex-platform update their haskell.nix
let patchHaskellNix = src:
      pkgs.runCommand "haskell-nix-patched" {} ''
        cp -r ${src} $out
        chmod -R +w $out
        sed -i 's#pkgs = import nixpkgs { };#pkgs = import nixpkgs { inherit system; };#' $out/default.nix
        sed -i 's#inherit (self) config;#inherit (self) config; localSystem = { inherit system; };#' $out/default.nix
      '';
in

{

  options = {

    importing = {

      "nixpkgs" = mkOption {
        type = types.raw;
        default = import config.thunks."nixpkgs" { inherit system; };
        defaultText = literalMD ''
          ```
          import config.thunks."nixpkgs" { inherit system; }
          ```
        '';
      };

      "haskell-nix" = mkOption {
        type = types.raw;
        default = import config.thunks."haskell-nix" { inherit system; };
        defaultText = literalMD ''
          ```
          import config.thunks."haskell-nix" { inherit system; }
          ```
        '';
      };

      "reflex-platform" = mkOption {
        type = types.raw;
        default = import config.thunks."reflex-platform" {
          inherit system;
          haskell-nix = import (patchHaskellNix (import (config.thunks."reflex-platform" + "/dep/haskell.nix/thunk.nix"))) { inherit system; };
        };
        defaultText = literalMD ''
          ```
          import config.thunks."reflex-platform" {
            inherit system;
            haskell-nix = import (config.thunks."reflex-platform" + "/dep/haskell.nix") { inherit system; };
          }
          ```
        '';
      };

      "nix-thunk" = mkOption {
        type = types.raw;
        default = import config.thunks."nix-thunk" {
          haskell-nix = import (patchHaskellNix (import (config.thunks."nix-thunk" + "/dep/haskell.nix/thunk.nix"))) { inherit system; };
        };
        defaultText = literalMD ''
          ```
          import config.thunks."nix-thunk" {
            haskell-nix = import (config.thunks."nix-thunk" + "/dep/haskell.nix") { inherit system; };
          }
          ```
        '';
      };

    };

  };

}
