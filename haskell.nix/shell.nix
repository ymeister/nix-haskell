{ pkgs ? project.pkgs
, project
, tools ? {}
, buildInputs ? []
, crossPlatforms ? []
, shellHook ? ""
}:

with pkgs.lib;

project.shellFor {
  tools = {
    cabal = "latest";
  } // tools;

  buildInputs = with pkgs; [
  ]
  ++ (optional (builtins.elem "ghcjs" crossPlatforms) [ nodejs-slim ])
  ++ buildInputs;

  crossPlatforms = ps: forEach crossPlatforms (p: ps."${p}");

  shellHook = ''
    function setup_cabal_to_nix {
      cabal_project_drv="$(nix-store -q --references "${project.plan-nix.drvPath}" | grep ".*-cabal.project.drv" - | head -n 1)"
      [ ! -z "$cabal_project_drv" ] && cabal_project_out="$(nix-store -q --outputs "$cabal_project_drv" | head -n 1)"
      [ ! -z "$cabal_project_out" ] && rm -f cabal.project.local && \cp -f "$cabal_project_out" cabal.project.local && chmod u+w cabal.project.local

      if [ -f cabal.project.local ]; then
        mkdir -p .nix
        store_paths="$(cat cabal.project.local | sed -n 's#.*\(/nix/store/.*\)#\1#p')"
        echo "$store_paths" | while read store_path; do
          target=".nix/$(echo "$store_path" | sed -n 's#/nix/store/\(.*\)#\1#p' | sed 's#/#-#g')"
          [ ! -e "$target" ] && cp -rf "$store_path" "$target" && chmod u+w -R "$target"
          sed -i "s#$store_path#$(readlink -f "$target")#g" cabal.project.local
        done
      fi
    }

    setup_cabal_to_nix 1> /dev/null

  '' + shellHook;
}
