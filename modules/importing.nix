{ config, lib, system, ... }:

with lib;

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
          haskell-nix = import (config.thunks."reflex-platform" + "/dep/haskell.nix") { inherit system; };
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
          haskell-nix = import (config.thunks."nix-thunk" + "/dep/haskell.nix") { inherit system; };
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
