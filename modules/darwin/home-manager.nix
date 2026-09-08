{ config, pkgs, ... }:

# Daily driver. Shared user plumbing (account, sketchybar, borders, homebrew
# policy, home-manager wiring, dock) comes from ./home-base.nix; this file
# holds what is specific to this machine: the SIP-off yabai/skhd config and
# the package, brew, cask and App Store lists.

let user = "schni"; in
{
  imports = [
    ./home-base.nix
  ];

  services.yabai = {
    enable = true;
    enableScriptingAddition = true;
    # The sudoers rule nix-darwin writes pins the absolute store path, and sudo
    # matches it as a string — a bare `sudo yabai` resolves via PATH to
    # /run/current-system/sw/bin/yabai, does not match, and fails with "a
    # password is required". Point the load-sa calls at the same store path.
    extraConfig =
      builtins.replaceStrings
        [ "sudo yabai --load-sa" ]
        [ "sudo ${config.services.yabai.package}/bin/yabai --load-sa" ]
        (builtins.readFile ./config/yabai/yabairc)
      + builtins.readFile ./config/yabai/rules;
  };

  services.skhd = {
    enable = true;
    # https://github.com/koekeishiya/skhd/blob/master/examples/skhdrc
    # https://github.com/koekeishiya/skhd/issues/1
    # Split so SIP-on hosts can swap only the space bindings (modules/pentest).
    skhdConfig =
      builtins.readFile ./config/skhd/skhdrc-spaces
      + builtins.readFile ./config/skhd/skhdrc-common;
  };

  homebrew = {
    brews = pkgs.callPackage ./brews.nix { };
    casks = pkgs.callPackage ./casks.nix { };

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    # If you have previously added these apps to your Mac App Store profile (but not installed them on this system),
    # you may receive an error message "Redownload Unavailable with This Apple ID".
    # This message is safe to ignore. (https://github.com/dustinlyons/nixos-config/issues/83)
    masApps = {
      "wireguard" = 1451685025;
      # Xcode is installed outside the App Store (no _MASReceipt), so a mas
      # entry is never "satisfied" and every rebuild tries to install it again.
      "Windows App" = 1295203466;
    };
  };

  home-manager.users.${user}.home.packages = pkgs.callPackage ./packages.nix { };
}
