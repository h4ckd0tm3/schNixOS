# Three sandbox/platform assumptions in visidata's test suite break the Darwin
# build. Linux dodges all three, so they went unnoticed upstream.
#
# 1. The tests run the real `vd` binary, which on Darwin resolves its data dir
#    to "$HOME/Library/Application Support/visidata". The build sandbox sets
#    HOME=/homeless-shelter, which is read-only, so every invocation dies
#    before writing output and all 168 shell tests report "no output".
# 2. test-vdx.sh points XDG_DATA_HOME at tests/xdg/data to supply the macro
#    fixtures, but visidata ignores XDG on Darwin, so macro-param-col-nosave
#    finds no "sort-by-col" macro. Link the macOS path at the same fixtures.
# 3. tests/testenv.sh creates the shared scratch dir (VD_TESTTMP) under a
#    hardcoded /tmp, which the sandbox denies. Point it at $TMPDIR instead.
#
# The hook is preCheck, not preInstallCheck: the package replaces
# installCheckPhase outright and only fires runHook preCheck/postCheck inside
# it. Drop once nixpkgs fixes this upstream.
self: super: {
  visidata = super.visidata.overrideAttrs (old: {
    preCheck = (old.preCheck or "") + ''
      export HOME=$(mktemp -d)
      mkdir -p "$HOME/Library/Application Support"
      ln -s "$PWD/tests/xdg/data/visidata" "$HOME/Library/Application Support/visidata"
      substituteInPlace tests/testenv.sh \
        --replace-fail '"/tmp/vd-tests-' '"$TMPDIR/vd-tests-'
    '';
  });
}
