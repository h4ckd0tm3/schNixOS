# nixpkgs' redis has a darwin-only postPatch that rewrites the hardcoded
# /Library/.../MacOSX.sdk path in the module Makefiles with --replace-fail.
# redis 8.10.3 no longer contains that path anywhere, so the substitution
# fails and blocks the pentest host build. Drop the postPatch on darwin.
# Delete once nixpkgs removes the substitution upstream.
self: super: {
  redis = super.redis.overrideAttrs (old: {
    postPatch = if super.stdenv.hostPlatform.isDarwin then "" else old.postPatch or "";
  });
}
