{ src,
  pkgs,
  extraCabalProject
}:

let extraCabal = map (a: ''
      printf '%s\n' ${pkgs.lib.escapeShellArg a} >> $out/cabal.project
    '') extraCabalProject;

in pkgs.runCommand "modify-project" {} (
  ''
    cp -r ${src} $out
    chmod +w $out
    if [ -f $out/cabal.project ]; then
      chmod +w $out/cabal.project
    fi
  '' + builtins.concatStringsSep "\n" extraCabal
)
