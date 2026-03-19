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
            flatten = prefix: attrs:
              nixpkgs.lib.foldlAttrs (acc: name: value:
                let key = if prefix == "" then name else "${prefix}-${name}";
                in if nixpkgs.lib.isDerivation value then acc // { ${key} = value; }
                   else if builtins.isAttrs value then acc // flatten key value
                   else acc
              ) {} attrs;
        in flatten "" project
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
