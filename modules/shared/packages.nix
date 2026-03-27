{ pkgs }:

with pkgs; [
  ### System Utilities
  btop
  coreutils
  killall
  fastfetch
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
  iftop

  ### Data Processing & CLI Tools
  jq
  yq-go
  unrar
  unzip

  ### Python Packages
  python3

  ### NUR Packages
  nur.repos.nodezeroat.hammer
]