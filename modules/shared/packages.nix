{ pkgs }:

with pkgs; [
  ### System Utilities
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
  yq-go
  unrar
  unzip

  ### Python Packages
  python3
  virtualenv
]