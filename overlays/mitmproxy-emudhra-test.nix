# mitmproxy 12.3.0's TestTlsConfig::test_emudhra verifies against roots the
# current CA bundle no longer trusts (eMudhra / Comodo AAA), failing with
# CERTIFICATE_VERIFY_FAILED and blocking the pentest host build. Skip only
# that test. Drop once nixpkgs disables or fixes it upstream.
self: super: {
  pythonPackagesExtensions = super.pythonPackagesExtensions ++ [
    (pyfinal: pyprev: {
      mitmproxy = pyprev.mitmproxy.overridePythonAttrs (old: {
        disabledTests = (old.disabledTests or [ ]) ++ [ "test_emudhra" ];
      });
    })
  ];
}
