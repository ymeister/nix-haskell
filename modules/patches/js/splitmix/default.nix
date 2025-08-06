{ ... }:

{

  config.overrides = [
    ({ ... }: {
      packages.splitmix.patches = [
        ./splitmix-js.patch
      ];
    })
  ];

}
