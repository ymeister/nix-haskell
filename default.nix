{ system ? builtins.currentSystem
, pkgs ? import ./pins/nixpkgs { inherit system; }
}:

with pkgs.lib;

module:

let eval = x: pkgs.lib.evalModules {
      modules = [
        ./modules

        {
          config.system = mkDefault system;
          config.importing.nixpkgs = mkDefault pkgs;
        }
        ({ config, ... }: {
          _module.args.system = mkDefault config.system;
          _module.args.pkgs = mkDefault config.importing.nixpkgs;
        })

        x
      ];

      specialArgs = {
        nix-haskell-modules = ./modules;
        nix-haskell-patches = ./modules/patches;
      };
    };

    evaluated = eval module;
    config = evaluated.config;
    options = evaluated.options;

    optionsDoc = pkgs.nixosOptionsDoc {
      inherit options;
      warningsAreErrors = false;
    };
    optionsDocMD = pkgs.runCommand "options-doc.md" {} ''
      cat ${optionsDoc.optionsCommonMark} >> $out
    '';
    optionsDocMan = pkgs.runCommand "options-doc.man" {} ''
      ${pkgs.pandoc}/bin/pandoc --standalone --to man ${optionsDocMD} -o $out
    '';
    viewManual = pkgs.writeShellScriptBin "manual" ''
      ${pkgs.man}/bin/man ${optionsDocMan}
    '';

    recursiveMerge = lhs: rhs:
      zipAttrsWith (name: values:
        if length values == 1 then head values
        else let l = elemAt values 0; r = elemAt values 1; in
          if isList l && isList r then l ++ r
          else if isAttrs l && isAttrs r then recursiveMerge l r
          else r
      ) [ lhs rhs ];

    haskell-nix =
      let mkProject = x:
            let config = (eval x).config;
                proj = config.haskell-nix.project;
                projOrShell = if !pkgs.lib.inNixShell
                  then proj
                  else proj.shell;
            in projOrShell // {
              inherit config;
              override = y: mkProject (inputs: recursiveMerge (x inputs) (y inputs));
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

  manual = {
    man = optionsDocMan;
    md = optionsDocMD;
    view = viewManual;
  };
}
