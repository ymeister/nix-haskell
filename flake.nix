{
  outputs = { self, nixpkgs, ... }:
    let eachSystem = nixpkgs.lib.genAttrs
          [ "x86_64-linux"
            "aarch64-linux"
          ];
    in {
      lib = eachSystem (system:
        let project = import ./default.nix { inherit system; };
        in {
          nix-haskell = project;
          haskell-nix = module: (project module).haskell-nix;
          manual = module: (project module).manual;
        }
      );

      packages = eachSystem (system:
        let project = import ./default.nix { inherit system; };
        in {
          manual = (project { src = ./.; }).manual;
          manualMarkdown = (project { src = ./.; }).manualMarkdown;
        }
      );
    };

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
