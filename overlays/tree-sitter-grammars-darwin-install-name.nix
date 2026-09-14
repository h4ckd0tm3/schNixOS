# nixpkgs links every tree-sitter grammar as `$CXX -shared -o parser`, so on
# darwin each grammar dylib carries the bare install name "parser". The
# python bindings (python3Packages.tree-sitter-grammars.*) are linked against
# that dylib with two-level namespace lookup, i.e. `_tree_sitter_<lang>
# (from parser)`. Once one grammar is loaded, dyld resolves every later
# grammar's "parser" reference to the already-loaded image, so only the first
# grammar per process works and the rest fail with
#   Symbol not found: _tree_sitter_python … Expected in: …-tree-sitter-json-…/parser
# graphify then reports "N .py file(s) contributed nothing … tree_sitter_python
# not installed" (#1745) for whatever language did not win the race.
#
# Give each dylib its own absolute install name so the bindings link against a
# unique path. Rebuilds the grammars and their python bindings locally.
# Drop once nixpkgs sets the install name in
# pkgs/by-name/tr/tree-sitter/grammars/build-grammar.nix.
self: super:
let
  inherit (super) lib;
  isGrammar = name: value: lib.hasPrefix "tree-sitter-" name && lib.isDerivation value;
  fixInstallName =
    drv:
    drv.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        if [ -f "$out/parser" ]; then
          install_name_tool -id "$out/parser" "$out/parser"
        fi
      '';
    });
in
lib.optionalAttrs super.stdenv.hostPlatform.isDarwin {
  tree-sitter-grammars = super.tree-sitter-grammars.overrideScope (
    _final: prev: lib.mapAttrs (_: fixInstallName) (lib.filterAttrs isGrammar prev)
  );
}
