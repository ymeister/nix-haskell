{ pkgs }:

{ mkProject ? pkgs.haskell-nix.project
, project # mkProject (haskell-nix.project) args
, deps ? [] # [ Path || { src = Path; cond = String || Null } ]
, shell ? {}
}:

let cabal = import ./cabal.nix { inherit pkgs; };

    dps = cabal.source-repository-packages deps;
    proj = mkProject (project // {
      inputMap =
        if builtins.hasAttr "inputMap" project
        then project.inputMap // dps.inputMap
        else dps.inputMap;
      cabalProject =
        if !(builtins.hasAttr "cabalProject" project) || project.cabalProject == null
        then cabal.import-cabal-project project.src "cabal.project"
        else cabal.import-cabal-project project.cabalProject;
      cabalProjectLocal =
        if !(builtins.hasAttr "cabalProjectLocal" project) || project.cabalProjectLocal == null
        then dps.cabalProjectLocal
        else project.cabalProjectLocal + ''

          ${dps.cabalProjectLocal}
        '';

      shell =
        if !(builtins.hasAttr "shell" project) || project.shell == null
        then projShell
        else project.shell // projShell;
    });
    projShell = {
      withHaddock = if pkgs.stdenv.hostPlatform.isGhcjs then false else true;
    };

in if !pkgs.lib.inNixShell
then proj
else import ./shell.nix (shell // { project = proj; })
