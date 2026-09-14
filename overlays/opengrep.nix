# opengrep (https://github.com/opengrep/opengrep) — the LGPL fork of semgrep's
# engine. Not in nixpkgs or homebrew-core; upstream only ships prebuilt
# single-file binaries on GitHub releases, so package those. Replaces the
# `semgrep` brew on both Macs. Drop once nixpkgs gains an `opengrep` package.
#
# Bump: change `version`, then for each asset
#   nix-prefetch-url https://github.com/opengrep/opengrep/releases/download/v<version>/<asset>
# and convert with `nix hash convert --hash-algo sha256 --to sri <hash>`.
self: super:
let
  version = "1.30.0";
  assets = {
    aarch64-darwin = {
      name = "opengrep_osx_arm64";
      hash = "sha256-D1vD3sCdmVxhMxpAF7hW7eUI+Q2VsBjZXx3GFmvon90=";
    };
    x86_64-linux = {
      name = "opengrep_manylinux_x86";
      hash = "sha256-NXeb3XLpISnI3yp38MVejAg1aAHqklke8yEI1rKNVkw=";
    };
    aarch64-linux = {
      name = "opengrep_manylinux_aarch64";
      hash = "sha256-pdWkpYul1G/1HpIWY9ocK7o49LA5h/Su7IfxbGrT7K4=";
    };
  };
  system = super.stdenv.hostPlatform.system;
  asset = assets.${system} or (throw "opengrep: no prebuilt binary for ${system}");
in
{
  opengrep = super.stdenvNoCC.mkDerivation {
    pname = "opengrep";
    inherit version;

    src = super.fetchurl {
      url = "https://github.com/opengrep/opengrep/releases/download/v${version}/${asset.name}";
      inherit (asset) hash;
    };

    dontUnpack = true;
    dontStrip = true; # single-file bundle; stripping breaks the embedded payload

    installPhase = ''
      runHook preInstall
      install -Dm755 $src $out/bin/opengrep
      runHook postInstall
    '';

    # The launcher unpacks itself to ~/.cache/opengrep/v<version>/ on first run;
    # the sandbox HOME is read-only, so point it at $TMPDIR for the check.
    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck
      HOME=$TMPDIR $out/bin/opengrep --version | grep -Fx "${version}"
      runHook postInstallCheck
    '';

    meta = with super.lib; {
      description = "Static code analysis engine, LGPL fork of semgrep (drop-in `opengrep scan`)";
      homepage = "https://github.com/opengrep/opengrep";
      license = licenses.lgpl21Only;
      sourceProvenance = [ sourceTypes.binaryNativeCode ];
      platforms = builtins.attrNames assets;
      mainProgram = "opengrep";
    };
  };
}
