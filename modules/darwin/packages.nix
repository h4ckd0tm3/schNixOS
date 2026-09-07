{ pkgs }:

# Home packages for the daily driver: the cross-platform CLI base, the macOS
# desktop infrastructure, plus anything only this machine wants.

let
  shared-packages = import ../shared/packages.nix { inherit pkgs; };
  desktop-base = import ./desktop-base.nix { inherit pkgs; };
in
shared-packages ++ desktop-base ++ [
]
