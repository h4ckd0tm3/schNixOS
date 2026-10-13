{ self, ... }:

# Daily driver. Everything shared with the other Macs lives in
# modules/darwin/common.nix; this file only picks the user module and the
# wallpaper.

{
  imports = [
    ../../modules/darwin/common.nix
    ../../modules/darwin/home-manager.nix
    ../../modules/shared
  ];

  # Togusa — Section 9's least-augmented member; the everyday counterpart to
  # the pentest box (kusanagi).
  networking = {
    computerName = "togusa";
    hostName = "togusa";
    localHostName = "togusa";
  };

  local.wallpaper = "${self}/hosts/wallpapers/mostwanted.png";
}
