{ config, lib, ... }:

with lib;

{

  options = {

    pins = {

      "nixpkgs" = mkOption {
        type = types.path;
        default = ../pins/nixpkgs;
      };

      "haskell-nix" = mkOption {
        type = types.path;
        default = ../pins/haskell.nix;
      };

      "reflex-platform" = mkOption {
        type = types.path;
        default = ../pins/reflex-platform;
      };

      "nix-thunk" = mkOption {
        type = types.path;
        default = ../deps/nix-thunk;
      };

    };

  };

}
