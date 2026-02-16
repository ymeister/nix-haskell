# GHCJS Cross-Compilation Support Module
#
# Provides GHCJS detection and configures shell dependencies for JavaScript
# compilation targets. GHCJS compiles Haskell to JavaScript, requiring Node.js
# template haskell.
#
# This module:
#   - Detects whether GHCJS is the current target (native or cross-compilation)
#   - Adds Node.js to shell.buildInputs when GHCJS is detected
#
# The `isGhcjs` option uses a two-part detection strategy:
#   1. Direct check: Is the host platform GHCJS? (native GHCJS build)
#   2. Cross-compilation check: Is GHCJS selected in shell.crossPlatforms?
#
# The cross-compilation detection works by creating a probe set that maps
# platform names to themselves (e.g., { ghcjs = "ghcjs"; wasi32 = "wasi32"; }).
# When crossPlatforms selects from this set, it returns platform name strings,
# allowing simple membership testing with `builtins.elem "ghcjs"`.

{ config, lib, pkgs, ... }:

with lib;

{

  options = {

    isGhcjs = mkOption {
      type = types.bool;
      default =
        let # Create probe set mapping each platform name to itself
            # e.g., { ghcjs = "ghcjs"; wasi32 = "wasi32"; mingwW64 = "mingwW64"; ... }
            probeSet = genAttrs (builtins.attrNames pkgs.pkgsCross) (name: name);
            # Get list of selected platform names as strings
            selected = config.shell.crossPlatforms probeSet;
        in # Native GHCJS: the shell itself is for a GHCJS platform
              pkgs.stdenv.hostPlatform.isGhcjs
           # Cross-compilation: GHCJS is among the selected cross targets
           || builtins.elem "ghcjs" selected;
      defaultText = ''
        let # Create probe set mapping each platform name to itself
            # e.g., { ghcjs = "ghcjs"; wasi32 = "wasi32"; mingwW64 = "mingwW64"; ... }
            probeSet = genAttrs (builtins.attrNames pkgs.pkgsCross) (name: name);
            # Get list of selected platform names as strings
            selected = config.shell.crossPlatforms probeSet;
        in # Native GHCJS: the shell itself is for a GHCJS platform
              pkgs.stdenv.hostPlatform.isGhcjs
           # Cross-compilation: GHCJS is among the selected cross targets
           || builtins.elem "ghcjs" selected;
      '';
      description = ''
        Whether the project targets GHCJS (either natively or via cross-compilation).
        Used to conditionally include JavaScript runtime dependencies.
      '';
    };

  };

  config = {

    shell = {

      # Node.js is required for template haskell
      buildInputs = mkIf config.isGhcjs (with pkgs; [
        nodejs-slim
      ]);

    };

  };

}
