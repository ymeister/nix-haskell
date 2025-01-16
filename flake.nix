{
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
          project = import ./default.nix { inherit pkgs; };
      in {
        lib.nix-haskell = project;
        lib.project = module: (project module).project;
        lib.manual = module: (project module).manual;

        packages.manual = (project { src = ./.; }).manual;
      }
    );
}
