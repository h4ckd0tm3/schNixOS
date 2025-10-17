{ pkgs }:

with pkgs;
let 
  shared-packages = import ../shared/packages.nix { inherit pkgs; };
in
shared-packages ++ [
  ### Window Management
  jankyborders # Window border styling
  yabai # Tiling window manager

  ### Status Bar & UI
  sketchybar # Customizable status bar
  sketchybar-app-font # Font for sketchybar app icons

  ### macOS System Utilities
  dockutil # Dock management CLI
  skhd # Hotkey daemon
  switchaudio-osx # Audio device switching
  nowplaying-cli # Media info CLI

  ### Development Tools
  pre-commit # Git pre-commit hooks

  ### Programming Languages & Runtimes
  cocoapods # iOS/macOS dependency manager
  go # Go programming language
  lua54Packages.lua # Lua scripting language
  rustup # Rust toolchain installer
]