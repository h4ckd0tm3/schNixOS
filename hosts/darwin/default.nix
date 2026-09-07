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

  local.wallpaper = "${self}/hosts/wallpapers/mostwanted.png";
}
