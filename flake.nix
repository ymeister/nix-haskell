{
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let project = import ./default.nix { inherit system; };
      in {
        lib.nix-haskell = project;
        lib.haskell-nix = module: (project module).haskell-nix;
        lib.manual = module: (project module).manual;

        packages.manual = (project { src = ./.; }).manual;
        packages.manualMarkdown = (project { src = ./.; }).manualMarkdown;
      }
    );

  nixConfig = {
    extra-substituters = [
      "https://nixcache.reflex-frp.org"
      "https://cache.iog.io"
    ];
    extra-trusted-public-keys = [
      "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI=" # reflex-frp
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
    allow-import-from-derivation = "true";
  };
}
