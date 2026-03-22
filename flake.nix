{
  outputs = { self, nixpkgs, ... }:
    let eachSystem = nixpkgs.lib.genAttrs
          [ "x86_64-linux"
            "aarch64-linux"
          ];
    in {
      lib = eachSystem (system:
        let nix-haskell = import ./default.nix { inherit system; };
        in {
          inherit nix-haskell;
        } // nixpkgs.lib.mapAttrs (name: _: module: (nix-haskell module).${name}) (nix-haskell {})
      );

      packages = eachSystem (system:
        let nix-haskell = import ./default.nix { inherit system; };
            project = nix-haskell { src = ./.; };
        in {
          manual-view = project.manual.view;
          manual-md = project.manual.md;
          manual-man = project.manual.man;
        }
      );
    };

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nixcache.reflex-frp.org"
      "https://cache.iog.io"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI=" # reflex-frp
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
    allow-import-from-derivation = "true";
  };
}
