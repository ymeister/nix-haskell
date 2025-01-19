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
}
