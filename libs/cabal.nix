{ pkgs }:

with pkgs.lib;

let # source-repository-package
    # :: String -> (Path || { src :: Path; condition :: String || Null } || { outPath :: Path; ... })
    # -> { inputMap."Path" :: AttrSet; cabalProject :: String }
    source-repository-package = name: package-repo:
      let hasOutPath = builtins.isAttrs package-repo && package-repo ? outPath;
          src = if hasOutPath then package-repo
                else if builtins.isAttrs package-repo && package-repo ? src then package-repo.src
                else package-repo;
          condition = if !hasOutPath && builtins.isAttrs package-repo && package-repo ? condition then package-repo.condition else null;
          resolved = if hasOutPath then package-repo else { inherit name; outPath = builtins.path { path = src; inherit name; }; };
          input = builtins.unsafeDiscardStringContext src;
      in {
        inputMap.${input} = resolved // { rev = "HEAD"; };
        cabalProject =
          if condition == null
          then ''
            source-repository-package
              type: git
              location: ${input}
              tag: HEAD
          ''
          else ''
            if ${condition}
              source-repository-package
                type: git
                location: ${input}
                tag: HEAD
          '';
      };

    # source-repository-packages
    # :: AttrSet (String -> Path || ...) -> { inputMap :: AttrSet; cabalProject :: String }
    source-repository-packages = package-repos:
      let packages = mapAttrsToList source-repository-package package-repos;
          zipPackages = builtins.zipAttrsWith
            (k: vs:
              if k == "cabalProject" then vs
              else builtins.zipAttrsWith (_: last) vs
            );

          zippedPackages = zipPackages packages;

      in {
        inputMap =
          if builtins.hasAttr "inputMap" zippedPackages
          then zippedPackages.inputMap
          else {};
        cabalProject = if builtins.hasAttr "cabalProject" zippedPackages
          then zippedPackages.cabalProject
          else "";
      };

    # import-cabal-project
    # :: Path (base directory)
    # -> Path (project file)
    # -> String
    import-cabal-project = dir: file:
      let path = dir + "/${file}";
          content = ''
            -- ${path}
            ${if hasPrefix "http://" file || hasPrefix "https://" file
              then builtins.fetchurl file
              else builtins.readFile path
            }
          '';
          lines = splitString "\n" content;

          parseLine = line:
            let splitLine = builtins.match "([ ]*)import: (.*)" line;
                prefix = builtins.elemAt splitLine 0;
                subproject = builtins.elemAt splitLine 1;
            in if splitLine != null
              then concatStringsSep "import: " [ prefix (import-cabal-project dir subproject) ]
              else line;
          parsed-lines = forEach lines parseLine;

      in concatStringsSep "\n" parsed-lines;

in {
  inherit source-repository-package source-repository-packages import-cabal-project;
}
