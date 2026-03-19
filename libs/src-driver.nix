{ src,
  pkgs,
  extraCabalProject
}:

let extraCabal = map (a: ''
      echo -e "\n${a}\n" >> $out/cabal.project
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
