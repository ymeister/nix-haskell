{ system ? builtins.currentSystem
, pkgs ? import ./pins/nixpkgs { inherit system; }
}:

module:

pkgs.lib.evalModules {
  modules = [
    ./modules

    {
      config.system = pkgs.lib.mkDefault system;
      config.importing.nixpkgs = pkgs.lib.mkDefault pkgs;
    }
    ({ config, ... }: {
      _module.args.system = pkgs.lib.mkDefault config.system;
      _module.args.pkgs = pkgs.lib.mkDefault config.importing.nixpkgs;
    })

    module
  ];

  specialArgs = {
    nix-haskell-modules = ./modules;
    nix-haskell-patches = ./modules/patches;
  };
}
