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
        default = import config.thunks."reflex-platform" { inherit system; };
        defaultText = literalMD ''
          ```
          import config.thunks."reflex-platform" { inherit system; }
          ```
        '';
      };

      "nix-thunk" = mkOption {
        type = types.raw;
        default = import config.thunks."nix-thunk" {};
        defaultText = literalMD ''
          ```
          import config.thunks."nix-thunk" {}
          ```
        '';
      };

    };

  };

}
