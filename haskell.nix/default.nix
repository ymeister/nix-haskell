{ pkgs }:

let project = import ./project.nix { inherit pkgs; };
    cabal = import ./cabal.nix { inherit pkgs; };

in {
  inherit project;
  inherit (cabal) source-repository-package source-repository-packages import-cabal-project;
}
