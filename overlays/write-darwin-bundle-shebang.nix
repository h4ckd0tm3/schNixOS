# nixpkgs' writeDarwinBundle (by-name/wr/writeDarwinBundle) lost its
# `#!${runtimeShell}` line, so bin/write-darwin-bundle is a bare script. The
# desktopToDarwinBundle hook execs it, bash falls back to running it via
# ENOEXEC, and that segfaults in fixupPhase. Breaks every package that builds
# a .app from a .desktop file (jadx on the pentest host). Put the shebang back.
# Delete once nixpkgs restores it upstream.
self: super: {
  writeDarwinBundle = super.writeDarwinBundle.overrideAttrs (old: {
    text = "#!${super.runtimeShell}\n" + old.text;
  });
}
