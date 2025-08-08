{ config, lib, pkgs, ... }:

with lib;

{

  config = {

    shell = {

      withHaddock = mkDefault (!pkgs.stdenv.hostPlatform.isGhcjs);

      buildInputs = mkDefault (with pkgs; [ nodejs-slim ]);

      shellHook = ''
        export EM_CACHE="$TMPDIR/em_cache"
      '';

    };

    overrides = [
      ({ config, ... }: {
        configureFlags = [ "--package-db ${config.ghc.package.outPath}/${config.ghc.package.libDir}/package.conf.d" ];
      })
    ];

    extraCabalProject = [
      ''
        if arch(javascript)
          extra-packages: ghci
      ''
    ];

  };

}
