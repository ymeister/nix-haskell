# Cross-Compilation Support Module
#
# Aggregates platform-specific cross-compilation support and provides
# common shell utilities for working with cross-compilation targets.
#
# Configuration:
#   shell.crossPlatforms - Function selecting which cross targets to support
#                          e.g., `ps: with ps; [ wasi32 ghcjs ]`

{ config, lib, pkgs, ... }:

{

  # Platform-specific cross-compilation support modules
  imports = [
    ./ghcjs  # JavaScript/GHCJS target support
  ];

  # Cross-Compilation Shell Wrapper Scripts
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
                  # Filter linker flags to remove native library paths that
                  # conflict with cross-compilation. The dev shell includes
                  # both native and cross-compiled dependencies, so
                  # NIX_LDFLAGS contains both native and target library
                  # paths. Passing native shared objects (e.g., native
                  # libffi.so) to the cross-linker causes "unknown file
                  # type" errors.
                  _filter_ldflags() {
                    local result=""
                    for arg in $1; do
                      if [[ "$arg" == -L* ]]; then
                        [[ "$arg" == *wasm* || "$arg" == *${targetPrefix}* ]] && result="$result $arg"
                      else
                        result="$result $arg"
                      fi
                    done
                    echo "$result"
                  }
                  export NIX_LDFLAGS="$(_filter_ldflags "$NIX_LDFLAGS")"
                  export NIX_LDFLAGS_FOR_TARGET="$(_filter_ldflags "$NIX_LDFLAGS_FOR_TARGET")"
                  PATH="${ghcWrapper}/bin:$PATH" exec "$@"
                ''
              );

    in builtins.concatMap mkWrapper crossPlatforms;

}
