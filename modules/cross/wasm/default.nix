# WASM Cross-Compilation Support Module
#
# Provides WASM detection and configures shell dependencies for WebAssembly
# compilation targets. WASM compiles Haskell to WebAssembly, requiring Node.js
# for template haskell.
#
# This module:
#   - Detects whether WASM is the current target (native or cross-compilation)
#   - Adds Node.js to shell.buildInputs when WASM is detected
#
# The `isWasm` option uses a two-part detection strategy:
#   1. Direct check: Is the host platform WASM? (native WASM build)
#   2. Cross-compilation check: Is a WASM target selected in shell.crossPlatforms?
#
# The cross-compilation detection works by creating a probe set that maps
# platform names to themselves (e.g., { ghcjs = "ghcjs"; wasi32 = "wasi32"; }).
# When crossPlatforms selects from this set, it returns platform name strings,
# allowing membership testing with `builtins.any`.

{ config, lib, pkgs, ... }:

with lib;

{

  options = {

    isWasm = mkOption {
      type = types.bool;
      default =
        let # Create probe set mapping each platform name to itself
            # e.g., { ghcjs = "ghcjs"; wasi32 = "wasi32"; mingwW64 = "mingwW64"; ... }
            probeSet = genAttrs (builtins.attrNames pkgs.pkgsCross) (name: name);
            # Get list of selected platform names as strings
            selected = config.shell.crossPlatforms probeSet;
        in # Native WASM: the shell itself is for a WASM platform
              pkgs.stdenv.hostPlatform.isWasm
           # Cross-compilation: a WASM target is among the selected cross targets
           || builtins.any (name: hasInfix "wasm" name || hasPrefix "wasi" name) selected;
      defaultText = ''
        let # Create probe set mapping each platform name to itself
            # e.g., { ghcjs = "ghcjs"; wasi32 = "wasi32"; mingwW64 = "mingwW64"; ... }
            probeSet = genAttrs (builtins.attrNames pkgs.pkgsCross) (name: name);
            # Get list of selected platform names as strings
            selected = config.shell.crossPlatforms probeSet;
        in # Native WASM: the shell itself is for a WASM platform
              pkgs.stdenv.hostPlatform.isWasm
           # Cross-compilation: a WASM target is among the selected cross targets
           || builtins.any (name: hasInfix "wasm" name || hasPrefix "wasi" name) selected;
      '';
      description = ''
        Whether the project targets WASM (either natively or via cross-compilation).
        Used to conditionally include WebAssembly runtime dependencies.
      '';
    };

  };

  config = {

    shell = {

      # Node.js is required for template haskell
      buildInputs = mkIf config.isWasm (with pkgs; [
        nodejs
      ]);

    };

  };

}
