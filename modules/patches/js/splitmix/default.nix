{ ... }:

let # Keep only overrides whose package name exists in the project,
    # so overrides for absent packages are silently skipped.
    mkOptionalPackages = { config, lib }:
      lib.filterAttrs (name: _: config.packages ? ${name});

in {

  config.overrides = [
    ({ config, lib, ... }: {
      packages = mkOptionalPackages { inherit config lib; } {
        splitmix.patches = [
          ./splitmix-js.patch
        ];
      };
    })
  ];

}
