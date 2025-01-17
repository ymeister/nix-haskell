{ pkgs ? import <nixpkgs> {} }:

with pkgs.lib;

module:

let eval = x: pkgs.lib.evalModules {
      modules = [
        {
          _module.args.pkgs = pkgs;
        }

        ./modules

        x
      ];
    };

    optionsDoc = pkgs.nixosOptionsDoc {
      inherit (eval module) options;
      warningsAreErrors = false;
    };
    optionsDocMD = pkgs.runCommand "options-doc.md" {} ''
      cat ${optionsDoc.optionsCommonMark} >> $out
    '';
    optionsDocMan = pkgs.runCommand "options-doc.man" {} ''
      ${pkgs.pandoc}/bin/pandoc --standalone --to man ${optionsDocMD} -o $out
    '';
    manual = pkgs.writeShellScriptBin "manual" ''
      ${pkgs.man}/bin/man ${optionsDocMan}
    '';

in rec {
  haskell-nix =
    let project = x:
          let config = (eval x).config;
              proj = config.haskell-nix.haskell-nix.project config.haskell-nix.project;
              projOrShell = if !pkgs.lib.inNixShell
                then proj
                else proj.shell;
          in projOrShell // {
            inherit config;
            override = y: project (recursiveUpdate x y);
          };
    in project module;

  inherit manual;
  manualMarkdown = optionsDocMD;
}
