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

    buildInputs = with pkgs;
    [
      gcc
      readline
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      darwin.apple_sdk.frameworks.CoreFoundation
    ];

    buildPhase = ''
        make bin/sketchybar.so
    '';
    
    installPhase = ''
      mkdir -p $out/lib
      mv bin/sketchybar.so $out/lib/sketchybar.so
    '';
  };
}