{ pkgs, ... }:

# The three C helpers sketchybar's Lua config shells out to. Each derivation
# sees only the files its makefile needs, so editing one helper (or a Lua
# file next to them) does not rebuild the others.

let
  inherit (pkgs) lib;
  helpers = ../config/sketchybar/helpers;

  mkHelper = { name, root, files }:
    pkgs.stdenv.mkDerivation {
      pname = name;
      version = "1.0";
      src = lib.fileset.toSource {
        inherit root;
        fileset = lib.fileset.unions files;
      };
      nativeBuildInputs = [ pkgs.clang pkgs.gnumake ];
      dontConfigure = true;
      buildPhase = "make -C ${name}";
      installPhase = "install -Dm755 ${name}/bin/${name} $out/bin/${name}";
      meta = {
        platforms = lib.platforms.darwin;
        mainProgram = name;
      };
    };
in
{
  cpuLoadBinary = mkHelper {
    name = "cpu_load";
    root = helpers + "/event_providers";
    files = [ (helpers + "/event_providers/cpu_load") (helpers + "/event_providers/sketchybar.h") ];
  };

  networkLoadBinary = mkHelper {
    name = "network_load";
    root = helpers + "/event_providers";
    files = [ (helpers + "/event_providers/network_load") (helpers + "/event_providers/sketchybar.h") ];
  };

  # menus/makefile links Carbon and SkyLight itself.
  menusBinary = mkHelper {
    name = "menus";
    root = helpers;
    files = [ (helpers + "/menus") ];
  };
}
