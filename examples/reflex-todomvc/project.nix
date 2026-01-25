{ config, nix-haskell-patches, ... }:

let nix-thunk = config.importing.nix-thunk;
    deps = with nix-thunk; mapSubdirectories thunkSource ./deps;

in {
  imports = [
    "${nix-haskell-patches}/js/splitmix"
  ];

  name = "reflex-todomvc";
  src = ./.;
  compiler-nix-name = "ghc914";

  source-repository-packages = {
    reflex-dom = deps.reflex-dom + "/reflex-dom";
    reflex-dom-core = deps.reflex-dom + "/reflex-dom-core";
  };

  extraSrcFiles = {
    library.extraSrcFiles = [
      "static/style.css"
    ];
    exes.reflex-todomvc.extraSrcFiles = [
      "static/style.css"
    ];
  };

  shell = {
    crossPlatforms = ps: with ps; [ ghcjs wasi32 ];
    packages = ps: with ps; [ reflex-todomvc ];
    withHaddock = false;
    withHoogle = false;
  };

}
