{ system ? builtins.currentSystem
, inputs ? {}
, pkgs ?
    if inputs ? nixpkgs
    then import inputs.nixpkgs { inherit system; }
    else import ./pins/nixpkgs { inherit system; }
}:

with pkgs.lib;

module:

let eval = import ./eval.nix { inherit system pkgs inputs; };

    evaluated = eval module;
    config = evaluated.config;
    options = evaluated.options;

    docs = import ./docs.nix { inherit pkgs options; };

    recursiveMerge = lhs: rhs:
      zipAttrsWith (name: values:
        if length values == 1 then head values
        else let l = elemAt values 0; r = elemAt values 1; in
          if isList l && isList r then l ++ r
          else if isAttrs l && isAttrs r then recursiveMerge l r
          else r
      ) [ lhs rhs ];

    haskell-nix =
      let asFunc = m: if builtins.isFunction m then m else _: m;
          mkProject = x: {
            config = (eval x).config;
            project = (eval x).config.haskell-nix.project;
            override = y: mkProject (inputs: recursiveMerge (asFunc x inputs) (asFunc y inputs));
          };
      in rec {
        project = mkProject module;

        ghcWithPackages = m: packages:
          let syntheticSrc = pkgs.writeTextFile {
                name = "ghc-with-packages-src";
                destination = "/ghc-with-packages.cabal";
                text = ''
                  cabal-version: 2.4
                  name: ghc-with-packages
                  version: 0
                '';
              };
              proj = (mkProject {
                name = "ghc-with-packages";
                src = syntheticSrc;
                cabalProject = ''
                  extra-packages: ${builtins.concatStringsSep ", " packages}
                '';
              }).override m;
          in proj.project.ghcWithPackages (ps: map (n: ps.${n}) packages);
      };


in {
  inherit config haskell-nix;

  nixpkgs = config.importing.nixpkgs;

  manual = docs;
} // mapAttrs (_: value: { haskell-nix = value; }) haskell-nix
