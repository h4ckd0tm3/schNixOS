# yabai master build: v7.1.25 + the #2799 fix ("scripting-addition add_space
# for macOS 26.6 Apple Silicon"), which repairs space creation / moving windows
# between spaces on macOS Tahoe. Delete this overlay once a release > 7.1.25
# lands in nixpkgs.
self: super: {
  yabai = super.yabai.overrideAttrs (old: rec {
    version = "7.1.25-unstable-2026-06-14";
    src = super.fetchFromGitHub {
      owner = "asmvik";
      repo = "yabai";
      rev = "dd845723416f5fe92af49fad5ebab00369e07edd";
      hash = "sha256-RPiGAuJS+tGsexekIzwgKYf/v+kA3lVn0+qMVIMC2Vk=";
    };
    # versionCheckHook would compare against the git version string; skip it.
    doInstallCheck = false;
  });
}
