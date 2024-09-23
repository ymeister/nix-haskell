{ pkgs ? null
, crossPlatform ? null

# haskell.nix
, haskellNix ? null # Path || Null
, haskellNix-nixpkgs ? "nixpkgs-unstable"
}:

assert (pkgs == null) -> (haskellNix != null);

if pkgs != null then
(
  let pkgs' = if crossPlatform == null then pkgs else pkgs.pkgsCross.${crossPlatform};
  in if builtins.hasAttr "haskell-nix" pkgs
    then import ./haskell.nix { pkgs = pkgs'; }
    else pkgs.haskell.lib
)

else if haskellNix != null then
(
  let haskellNix' = import haskellNix {};

      # Import nixpkgs and pass the haskell.nix provided nixpkgsArgs
      pkgs'' = import
        # haskell.nix provides access to the nixpkgs pins which are used by our CI,
        # hence you will be more likely to get cache hits when using these.
        # But you can also just use your own, e.g. '<nixpkgs>'.
        haskellNix'.sources.${haskellNix-nixpkgs}
        # These arguments passed to nixpkgs, include some patches and also
        # the haskell.nix functionality itself as an overlay.
        haskellNix'.nixpkgsArgs;
      pkgs' = if crossPlatform == null then pkgs'' else pkgs''.pkgsCross.${crossPlatform};

  in (import ./haskell.nix { pkgs = pkgs'; }) // { pkgs = pkgs'; }
)

else {}
