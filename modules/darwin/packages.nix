{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  dockutil
  sketchybar
  sketchybar-app-font
  jankyborders
  skhd
  yabai
  switchaudio-osx
  nowplaying-cli
  lua54Packages.lua
]
