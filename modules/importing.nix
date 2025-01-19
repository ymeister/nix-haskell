{ config, lib, ... }:

with lib;

{

  options = {

    importing = {

      "nixpkgs" = mkOption {
        type = types.raw;
        default = import config.thunks."nixpkgs" {};
        defaultText = literalMD ''
          ```
          import config.thunks."nixpkgs" {}
          ```
        '';
      };

      "haskell-nix" = mkOption {
        type = types.raw;
        default = import config.thunks."haskell-nix" {};
        defaultText = literalMD ''
          ```
          import config.thunks."haskell-nix" {}
          ```
        '';
      };

      "reflex-platform" = mkOption {
        type = types.raw;
        default = import config.thunks."reflex-platform" {};
        defaultText = literalMD ''
          ```
          import config.thunks."reflex-platform" {}
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
