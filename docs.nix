{ pkgs, options }:

let optionsDoc = pkgs.nixosOptionsDoc {
      inherit options;
      warningsAreErrors = false;
    };

    optionsDocMD = pkgs.runCommand "options-doc.md" {} ''
      sed 's|/nix/store/[a-z0-9]\{32\}-source|<nix-haskell>|g' ${optionsDoc.optionsCommonMark} > $out
    '';

    optionsDocMan = pkgs.runCommand "options-doc.man" {} ''
      ${pkgs.pandoc}/bin/pandoc --standalone --to man ${optionsDocMD} -o $out
    '';

    viewManual = pkgs.writeShellScriptBin "manual" ''
      ${pkgs.man}/bin/man ${optionsDocMan}
    '';

in {
  md = optionsDocMD;
  man = optionsDocMan;
  view = viewManual;
}
