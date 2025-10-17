self: super: with super;  {
  sbar-lua = let
    pname = "SketchyBarLua";
    version = "unstable-2024-08-12"; # Use a specific tag or commit hash if desired
  in stdenv.mkDerivation rec {
    name = "${pname}-${version}";
    src = pkgs.fetchFromGitHub {
      owner = "FelixKratz";
      repo = "SbarLua";
      rev = "437bd2031da38ccda75827cb7548e7baa4aa9978"; # Replace with a specific commit or tag for stability.
      sha256 = "sha256-F0UfNxHM389GhiPQ6/GFbeKQq5EvpiqQdvyf7ygzkPg=";
    };

    nativeBuildInputs = with pkgs; [clang gnumake];
    buildInputs = with pkgs; [readline gcc];

    NIX_LDFLAGS =
      lib.optionalString stdenv.hostPlatform.isDarwin
      "-framework CoreFoundation";

    makeFlags = lib.optionals stdenv.hostPlatform.isDarwin ["CC=cc"];

    buildPhase = ''
      make bin/sketchybar.so
    '';
    
    installPhase = ''
      mkdir -p $out/lib
      mv bin/sketchybar.so $out/lib/sketchybar.so
    '';
  };
}