{ system ? builtins.currentSystem
, pkgs ? import ./pins/nixpkgs { inherit system; }
, inputs ? {}
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
          mkProject = x:
            let config = (eval x).config;
                proj = config.haskell-nix.project;
            in proj // {
              inherit config;
              override = y: mkProject (inputs: recursiveMerge (asFunc x inputs) (asFunc y inputs));
            };
      in {
        project = mkProject module;
      };


in {
  inherit config haskell-nix;

  nixpkgs = config.importing.nixpkgs;

  project = {
    haskell-nix = haskell-nix.project;
  };

  manual = docs;
}
