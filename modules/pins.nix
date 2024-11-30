{ config, lib, ... }:

with lib;

{

  options = {

    pins = {

      "nix-thunk" = mkOption {
        type = types.path;
        default = ../deps/nix-thunk;
      };

      "haskell-nix" = mkOption {
        type = types.path;
        default = ../pins/haskell.nix;
      };

      "reflex-platform" = mkOption {
        type = types.path;
        default = ../pins/reflex-platform;
      };

    };

  };

}
