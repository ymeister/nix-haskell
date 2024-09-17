{ pkgs }:

{ mkProject ? pkgs.haskell-nix.project
, project # mkProject (haskell-nix.project) args
, deps ? [] # [ Path || { src = Path; cond = String || Null } ]
}:

let cabal = import ./cabal.nix { inherit pkgs; };

    dps = cabal.source-repository-packages deps;
    prj = project // {
      inputMap =
        if builtins.hasAttr "inputMap" project
        then project.inputMap // dps.inputMap
        else dps.inputMap;
      cabalProject =
        if !(builtins.hasAttr "cabalProject" project) || builtins.isNull project.cabalProject
        then cabal.import-cabal-project project.src "cabal.project"
        else cabal.import-cabal-project project.cabalProject;
      cabalProjectLocal =
        if !(builtins.hasAttr "cabalProjectLocal" project) || builtins.isNull project.cabalProjectLocal
        then dps.cabalProjectLocal
        else project.cabalProjectLocal + ''

          ${dps.cabalProjectLocal}
        '';

      shell.withHaddock = if pkgs.stdenv.hostPlatform.isGhcjs then false else true;
    };

in mkProject prj
