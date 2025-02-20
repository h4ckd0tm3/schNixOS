self: super: with super; {
  berkeley-mono = let
    version = "250213R4469MJ0LR";
    pname = "berkeley-mono";
    ticket-id = "742VZ7YN";
  in stdenv.mkDerivation {
    name = "${pname}-${version}";

    src = requireFile {
      name = "Berkeley_Mono_${version}.zip";
      url = "https://usgraphics.com/products/berkeley-mono";
      sha256 = "0ygf4i5f56hnpk62aj0nqy197995r0qk00lr67dc1cnr6d8rzq3a";
    };

    buildInputs = [ unzip ];
    phases = [ "unpackPhase" "installPhase" ];

    unpackPhase = ''
      echo "Unpacking Berkeley Mono font..."
      mkdir -p $TMPDIR/unpacked
      unzip $src -d $TMPDIR/unpacked
      mv $TMPDIR/unpacked/${version}/TX-02-${ticket-id}/*.otf $TMPDIR/unpacked/.
    '';

    installPhase = ''
      mkdir -p $out/share/fonts
      cp $TMPDIR/unpacked/*.otf $out/share/fonts/
    '';

    meta = with lib; {
      homepage = "https://usgraphics.com/products/berkeley-mono";
      description = "Berkeley Mono™ — A beautifully crafted monospace font for developers and designers.";
      license = licenses.unfree;
      platforms = platforms.all;
    };
  };
}

# Download Font
# Fill in version and Ticket ID
# Run nix-prefetch-url --type sha256 file:///path/to/font.zip
# Replace sha256 hash
# Build and Switch