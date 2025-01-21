## Nix-Haskell


### Example

```
let nix-haskell = import ./deps/nix-haskell {};
    pkgs = nix-haskell.nixpkgs;

    nix-thunk = import ./deps/nix-thunk {};
    deps = with nix-thunk; mapSubdirectories thunkSource ./deps;

in with pkgs.lib; nix-haskell {
  src = ./.;
  compiler-nix-name = "ghc910";

  source-repository-packages = [
    obelisk-frontend = deps.obelisk + "/lib/frontend";
    obelisk-backend = {
      src = deps.obelisk + "lib/backend";
      condition = "!arch(javascript);"
    };

    reflex-dom = deps.reflex-dom + "/reflex-dom";
    reflex-dom-core = deps.reflex-dom + "/reflex-dom-core";
    reflex = deps.reflex;
    patch = deps.patch;
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
    packages = ps: with ps; [ common frontend "backend" ];
  };

  haskell-nix.project = {
    # haskell.nix specific overrides
  };

  # TODO
  #reflex-platform.project = {
  #  # reflex-platform specific overrides
  #};
}
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
