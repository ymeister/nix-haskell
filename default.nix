{ pkgs ? import <nixpkgs> {} }:

module:

let eval = pkgs.lib.evalModules {
      modules = [
        {
          _module.args.pkgs = pkgs;
        }

        ./modules

        module
      ];
    };

    optionsDoc = pkgs.nixosOptionsDoc {
      inherit (eval) options;
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
  inherit manual;

  project = {
    config = eval.config;
    haskell-nix =
      let proj = eval.config.haskell-nix.haskell-nix.project eval.config.haskell-nix.project;
      in if !pkgs.lib.inNixShell
        then proj
        else proj.shell;
  };
}
