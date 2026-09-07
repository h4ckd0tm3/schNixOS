{ pkgs }:

# Window manager, status bar and toolchain packages every macOS host needs.
# Infrastructure only — apps stay in each host's own packages.nix / casks.nix
# (see modules/pentest/README.md for why those lists are opt-in).

with pkgs; [
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

  ### Programming Languages & Runtimes
  cocoapods # iOS/macOS dependency manager
  go # Go programming language
  lua55Packages.lua # Lua scripting language (same major as sbarlua / sketchybarrc)
  rustup # Rust toolchain installer
]
