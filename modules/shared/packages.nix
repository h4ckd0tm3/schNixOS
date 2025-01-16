{ pkgs }:

with pkgs; [
  # General packages for development and system management
  bat
  btop
  coreutils
  killall
  neofetch
  openssh
  sqlite
  wget
  zip
  lsd
  lazygit

  # Text and terminal utilities
  htop
  iftop
  jq
  tree
  unrar
  unzip
  zsh-powerlevel10k

  # Python packages
  python3
  virtualenv
]
