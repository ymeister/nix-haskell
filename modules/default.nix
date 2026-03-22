{ ... }:

{

  imports = [
    ./common.nix
    ./haskell.nix

    ./cross

    ./importing.nix
    ./optimizations.nix
    ./pins.nix
    ./thunks.nix
  ];

}
