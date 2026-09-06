# plumbum's test_pgrep is sandbox-flaky (asserts pgrep finds a live process
# inside the empty nix build sandbox) and blocks rpyc -> pwntools on the
# pentest host. Skip only that test. Drop once nixpkgs disables it upstream.
self: super: {
  pythonPackagesExtensions = super.pythonPackagesExtensions ++ [
    (pyfinal: pyprev: {
      plumbum = pyprev.plumbum.overridePythonAttrs (old: {
        disabledTests = (old.disabledTests or [ ]) ++ [ "test_pgrep" ];
      });
    })
  ];
}
