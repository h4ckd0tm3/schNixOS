{ pkgs }:

with pkgs;
let 
  shared-packages = import ../shared/packages.nix { inherit pkgs; };
in
shared-packages ++ [
  ### Window & UI Management
  "dockutil"
  "sketchybar"
  "sketchybar-app-font"
  "jankyborders"
  "yabai"

  ### Keybinding & Automation
  "skhd"

  ### Audio Utilities
  "switchaudio-osx"
  "nowplaying-cli"

  ### Development Tools
  "lua54Packages.lua"
  "cocoapods"
]