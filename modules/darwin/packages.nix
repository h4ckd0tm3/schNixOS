{ pkgs }:

# Home packages for the daily driver: the cross-platform CLI base and the macOS
# desktop infrastructure. Append a list here for anything only this machine
# wants (apps come from casks.nix / brews.nix).

let
  shared-packages = import ../shared/packages.nix { inherit pkgs; };
  desktop-base = import ./desktop-base.nix { inherit pkgs; };
in
shared-packages ++ desktop-base
