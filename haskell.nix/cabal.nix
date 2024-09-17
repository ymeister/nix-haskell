{ pkgs }:

with pkgs.lib;

let source-repository-package = package-repo:
      let src = if builtins.isAttrs package-repo then package-repo.src else package-repo;
          cond = if builtins.isAttrs package-repo then package-repo.cond else null;
          input = builtins.unsafeDiscardStringContext src;
      in {
        inputMap."${input}" = { name = builtins.baseNameOf src; outPath = src; rev = "HEAD"; };
        cabalProjectLocal =
          if builtins.isNull cond
          then ''
            source-repository-package
              type: git
              location: ${input}
              tag: HEAD
          ''
          else ''
            if ${cond}
              source-repository-package
                type: git
                location: ${input}
                tag: HEAD
          '';
      };

    source-repository-packages = with pkgs.lib; package-repos:
      let packages = forEach package-repos source-repository-package;
          zipPackages = builtins.zipAttrsWith
            (k: vs:
              if k == "cabalProjectLocal" then concatStringsSep "\n" vs
              else builtins.zipAttrsWith (_: last) vs
            );

      in zipPackages packages;

    import-cabal-project = with pkgs.lib; dir: file:
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
