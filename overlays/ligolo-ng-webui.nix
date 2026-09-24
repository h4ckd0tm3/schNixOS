# ligolo-ng 0.9.x ships a WebUI, but nixpkgs' package only compiles the Go
# `cmd/agent` + `cmd/proxy` binaries and never builds the frontend. The proxy
# embeds `web/dist` via `//go:embed`, and the release tarball commits only a
# placeholder there:
#     Ligolo-ng WebUI is not built! Please read the documentation.
# The real frontend lives in the `web/ligolo-ng-web` git submodule (a Vite +
# React app), which GitHub archive tarballs omit, so nixpkgs' src can't build
# it. Upstream's own release process runs `go generate ./web` first, which does
#     npm install -C ligolo-ng-web && npm run build-ligolo -C ligolo-ng-web
# writing the compiled assets into `web/dist` before `go build`.
#
# This overlay reproduces that: build the submodule frontend with
# buildNpmPackage, then drop the result into `web/dist` before the Go build so
# `//go:embed dist` picks up the real WebUI. `vite.config.ts` uses base "./",
# so the assets self-host correctly from the proxy.
#
# Bump alongside nixpkgs' ligolo-ng: set `webRev` to the submodule commit at the
# new tag —
#   curl -s "https://api.github.com/repos/nicocha30/ligolo-ng/contents/web/ligolo-ng-web?ref=v<version>"
# then refresh `hash` (nix store prefetch-file --unpack <tarball>) and
# `npmDepsHash` (nix run nixpkgs#prefetch-npm-deps -- package-lock.json).
# Drop this overlay once nixpkgs builds the WebUI itself.
self: super:
let
  webRev = "d26d393468335c599e60a5311ac7fef9fcf738be"; # submodule @ ligolo-ng v0.9.1

  ligolo-ng-web = super.buildNpmPackage {
    pname = "ligolo-ng-web";
    version = "0.9.1";

    src = super.fetchFromGitHub {
      owner = "nicocha30";
      repo = "ligolo-ng-web";
      rev = webRev;
      hash = "sha256-iGf7ZwFydC6QGjYKRTd278pnEW+ha98KK1ZcH0qkdIE=";
    };

    npmDepsHash = "sha256-lUnclHqmrEbKAbnVGxM7hlgARJYGrM7ezLuEdOq5qIA=";

    # `build` == `tsc && vite build` (outDir ./dist); `build-ligolo` is the same
    # but writes to ../dist. We capture ./dist ourselves.
    npmBuildScript = "build";

    installPhase = ''
      runHook preInstall
      cp -r dist "$out"
      runHook postInstall
    '';
  };
in
{
  ligolo-ng = super.ligolo-ng.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      rm -rf web/dist
      cp -r ${ligolo-ng-web} web/dist
      chmod -R u+w web/dist
    '';
  });
}
