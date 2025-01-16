## Nix-Haskell


### Example

```
{ pkgs ? import <nixpkgs> {} }:

with pkgs.lib;

let nix-thunk = import ./deps/nix-thunk {};
    deps = with nix-thunk; mapSubdirectories thunkSource ./deps;

    nix-haskell = import ./deps/nix-haskell { inherit pkgs; };

in nix-haskell {
  src = ./.;
  compiler-nix-name = "ghc910";

  source-repository-packages = [
    (deps.obelisk + "/lib/executable-config/inject")
    (deps.obelisk + "/lib/executable-config/lookup")
    (deps.obelisk + "/lib/frontend")
    (deps.obelisk + "/lib/route")
    (deps.obelisk + "/lib/tabulation")
    { src = deps.obelisk + "/lib/asset/manifest"; condition = "!arch(javascript)"; }
    { src = deps.obelisk + "/lib/asset/serve-snap"; condition = "!arch(javascript)"; }
    { src = deps.obelisk + "/lib/backend"; condition = "!arch(javascript)"; }
    { src = deps.obelisk + "/lib/command"; condition = "!arch(javascript)"; }
    { src = deps.obelisk + "/lib/run"; condition = "!arch(javascript)"; }
    { src = deps.obelisk + "/lib/selftest"; condition = "!arch(javascript)"; }
    { src = deps.obelisk + "/lib/snap-extras"; condition = "!arch(javascript)"; }
    { src = deps.reflex-fsnotify; condition = "!arch(javascript)"; }

    (deps.reflex-dom + "/reflex-dom")
    (deps.reflex-dom + "/reflex-dom-core")
    deps.reflex
    deps.patch
  ];

  extraCabalProject = [
    (builtins.readFile (deps.obelisk + "/lib/cabal.dependencies.project"))
    (builtins.readFile (deps.reflex-dom + "/cabal.dependencies.project"))
    (builtins.readFile (deps.reflex-fsnotify + "/cabal.dependencies.project"))
  ];

  overrides = [
    ({ pkgs, lib, ... }: {
      enableDeadCodeElimination = true;
      packages = {
        obelisk-command.components.library.build-tools = with pkgs; [ ghcid jre openssh ];
        cli-git.components.library.build-tools = with pkgs; [ git ];
        cli-nix.components.library.build-tools = with pkgs; [ nix nix-prefetch-git ];

        reflex-dom-core.components.tests = {
          gc.buildable = lib.mkForce false;
          hydration.buildable = lib.mkForce false;
        };
      };
    })
  ];

  shell = {
    crossPlatforms = ps: with ps; [ ghcjs ];
    packages = ps: concatMap (p: optional (builtins.hasAttr p ps) ps."${p}") [ "common" "frontend" "backend" ];
  };

  haskell-nix.project = {
    # haskell.nix specific options
  };

  # TODO
  #reflex-platform.project = {
  #  # reflex-platform specific options
  #};

```



### Modules documentation

```
nix run --no-write-lock-file --impure github:reflex-frp/nix-haskell#manual
```

or

[Modules Documentation](docs/modules.md)



### Pins overrides

```
{
  pins.haskell-nix = ./dep/your-haskell-nix;

  thunks.reflex-platform = thunkSource ./dep/your-reflex-platform;

  importing.reflex-platform = import your_reflex_platform {};
}
```
