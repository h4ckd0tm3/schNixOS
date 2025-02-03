{ pkgs, config, ... }:

{
  ".config/kitty/macos-launch-services-cmdline" = {
    text = "--listen-on unix:/tmp/mykitty.sock";
  };
}
