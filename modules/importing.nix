{ config, lib, ... }:

with lib;

{

  options = {

    importing = {

      "nix-thunk" = mkOption {
        type = types.raw;
        default = import config.thunks."nix-thunk" {};
        defaultText = literalMD ''
          ```
          import config.thunks."nix-thunk" {}
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

    };

  };

}
