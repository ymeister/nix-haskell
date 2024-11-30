{ config, lib, ... }:

with lib;

{

  options = {

    thunks = mapAttrs
      ( name: value: mkOption {
          type = types.path;
          default =
            if name == "nix-thunk"
            then (import ../deps/nix-thunk {}).thunkSource value
            else config.importing."nix-thunk".thunkSource value;
      }) config.pins;

  };

}
