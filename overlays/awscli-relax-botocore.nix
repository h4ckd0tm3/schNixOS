# nixpkgs bumped botocore/s3transfer without bumping awscli v1, whose
# pythonRuntimeDepsCheck then rejects botocore==1.42.31 / s3transfer<0.17.
# awscli v1 is only pulled in by pacu on the pentest host. Relax the pins.
# Delete once nixpkgs ships a matching awscli version.
self: super: {
  awscli = super.awscli.overridePythonAttrs (old: {
    pythonRelaxDeps = (old.pythonRelaxDeps or [ ]) ++ [
      "botocore"
      "s3transfer"
    ];
  });
}
