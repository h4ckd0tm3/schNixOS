# nixpkgs' rust cargo-setup-hook now runs cargoUseSystemLibs, which forces
# vendored -sys crates onto system libraries (ZSTD_SYS_USE_PKG_CONFIG=1,
# AWS_LC_SYS_USE_SYSTEM=1, JEMALLOC_OVERRIDE=..., ...). Packages whose inputs
# weren't updated panic in their -sys build scripts and fail the pentest build:
#   apkeep     -> zstd, aws-lc
#   oha        -> aws-lc, jemalloc, sqlite, zstd, openssl, pkg-config
#                 (on darwin it had none of them)
#   kingfisher -> aws-lc   (pulled in by prowler)
# Delete each entry once nixpkgs adds the inputs upstream.
self: super:
let
  addInputs = pkg: { build ? [ ], native ? [ ] }: pkg.overrideAttrs (old: {
    buildInputs = (old.buildInputs or [ ]) ++ build;
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ native;
  });
in {
  apkeep = addInputs super.apkeep { build = [ super.zstd super.aws-lc ]; };
  oha = addInputs super.oha {
    build = with super; [ aws-lc rust-jemalloc-sys sqlite zstd openssl ];
    native = [ super.pkg-config ];
  };
  kingfisher = addInputs super.kingfisher { build = [ super.aws-lc ]; };
}
