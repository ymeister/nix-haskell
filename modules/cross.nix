# Cross-Compilation Shell Wrapper Module
#
# Adds convenience wrapper scripts to shell.buildInputs for each configured
# cross-compilation target. These wrappers allow running cross-compiler tools
# without specifying the target prefix.
#
# Example - with a WASM cross-compilation target, instead of running:
#   wasm32-unknown-wasi-ghc --version
#   wasm32-unknown-wasi-ghc-pkg list
#
# You can use the wrapper script:
#   wasm32-unknown-wasi ghc --version
#   wasm32-unknown-wasi ghc-pkg list
#
# Configuration:
#   shell.crossPlatforms - Function selecting which cross targets to support
#                          e.g., `ps: with ps; [ wasi32 ghcjs ]`

{ config, lib, pkgs, ... }:

{

  shell.buildInputs =
    let # List of cross-compiled projects from user's crossPlatforms selection
        crossPlatforms = config.shell.crossPlatforms config.haskell-nix.project.projectCross;

        # Creates a wrapper script for a single cross-compilation target
        mkWrapper = projectCross:
          let # Wrapped GHC from the cross-compiled project's shell
              ghc = projectCross.shell.ghc;

              # Target prefix without trailing dash (e.g., "wasm32-unknown-wasi-" -> "wasm32-unknown-wasi")
              targetPrefix = lib.removeSuffix "-" ghc.targetPrefix;

              # Directory with symlinks: wasm32-unknown-wasi-ghc -> ghc, etc.
              # Allows tools to be called without prefix when this dir is in PATH
              ghcWrapper = pkgs.runCommand "${targetPrefix}-ghc-wrapper" {} ''
                  mkdir -p $out/bin
                  for i in ${ghc.outPath}/bin/${targetPrefix}-*; do
                    name=$(basename "$i")
                    ln -s "$i" $out/bin/''${name#${targetPrefix}-}
                  done
                '';

          # Only create wrapper for cross-compilation (skip if no target prefix)
          in lib.optional ((targetPrefix != null) && (targetPrefix != ""))
              (
                # Script named after target that runs commands with wrapper in PATH
                pkgs.writeShellScriptBin "${targetPrefix}" ''
                  PATH="${ghcWrapper}/bin:$PATH" exec "$@"
                ''
              );

    in builtins.concatMap mkWrapper crossPlatforms;

}
