{ pkgs }:

with pkgs; [
  ### System Utilities
  bat
  btop
  coreutils
  killall
  neofetch
  openssh
  wget
  zip

  ### Development Tools
  sqlite
  lazygit
  typst

  ### Terminal Enhancements
  lsd
  tree
  zsh-powerlevel10k

  ### Monitoring & Network
  htop
  iftop

  ### Data Processing & CLI Tools
  jq
  unrar
  unzip

  ### Python Packages
  python3
  virtualenv
]