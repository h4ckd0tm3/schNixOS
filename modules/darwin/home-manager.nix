{ config, pkgs, lib, home-manager, ... }:

let
  user = "schni";
  sharedFiles = import ../shared/files.nix { inherit config pkgs; };
  additionalFiles = import ./files.nix { inherit user config pkgs; };
in
{
  imports = [
   ./dock
  ];

  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  # Services
  services.sketchybar = {
    enable = true;
    package = pkgs.sketchybar;
  };

  services.yabai = {
    enable = true; 
    enableScriptingAddition = true;
    package = pkgs.yabai;
    config = {
        extraConfig = builtins.readFile ./config/yabai/yabairc;
    };
  };

  services.skhd = {
    enable = true;
    package = pkgs.skhd;
    # https://github.com/koekeishiya/skhd/blob/master/examples/skhdrc
    # https://github.com/koekeishiya/skhd/issues/1
    skhdConfig = ''
      ## Navigation (lalt - ...)
      # Space Navigation (four spaces per display): lalt - {1, 2, 3, 4}
      lalt - 1 : SPACES=($(yabai -m query --displays --display | jq '.spaces[]')) && [[ -n $SPACES[1] ]] && yabai -m space --focus $SPACES[1]
      lalt - 2 : SPACES=($(yabai -m query --displays --display | jq '.spaces[]')) && [[ -n $SPACES[2] ]] && yabai -m space --focus $SPACES[2]
      lalt - 3 : SPACES=($(yabai -m query --displays --display | jq '.spaces[]')) && [[ -n $SPACES[3] ]] && yabai -m space --focus $SPACES[3]
      lalt - 4 : SPACES=($(yabai -m query --displays --display | jq '.spaces[]')) && [[ -n $SPACES[4] ]] && yabai -m space --focus $SPACES[4]

      # Window Navigation (through display borders): lalt - {j, k, l, ö}
      lalt - j    : yabai -m window --focus west  || yabai -m display --focus west
      lalt - k    : yabai -m window --focus south || yabai -m display --focus south
      lalt - l    : yabai -m window --focus north || yabai -m display --focus north
      lalt - 0x29 : yabai -m window --focus east  || yabai -m display --focus east

      # Extended Window Navigation: lalt - {h, ä}
      lalt -    h : yabai -m window --focus first
      lalt - 0x27 : yabai -m window --focus  last

      # Float / Unfloat window: lalt - space
      lalt - space : yabai -m window --toggle float; sketchybar --trigger window_focus

      # Make window zoom to fullscreen: shift + lalt - f
      ctrl + shift - f : yabai -m window --toggle native-fullscreen; sketchybar --trigger window_focus
      shift + lalt - f : yabai -m window --toggle zoom-fullscreen; sketchybar --trigger window_focus

      # Make window zoom to parent node: lalt - f
      lalt - f : yabai -m window --toggle zoom-parent; sketchybar --trigger window_focus

      ## Window Movement (shift + lalt - ...)
      # Moving windows in spaces: shift + lalt - {j, k, l, ö}
      shift + lalt - j : yabai -m window --warp west || $(yabai -m window --display west && yabai -m display --focus west && yabai -m window --warp last) || yabai -m window --move rel:-10:0
      shift + lalt - k : yabai -m window --warp south || $(yabai -m window --display south && yabai -m display --focus south) || yabai -m window --move rel:0:10
      shift + lalt - l : yabai -m window --warp north || $(yabai -m window --display north && yabai -m display --focus north) || yabai -m window --move rel:0:-10
      shift + lalt - 0x29 : yabai -m window --warp east || $(yabai -m window --display east && yabai -m display --focus east && yabai -m window --warp first) || yabai -m window --move rel:10:0

      # Toggle split orientation of the selected windows node: shift + lalt - s
      shift + lalt - s : yabai -m window --toggle split

      # Moving windows between spaces: shift + lalt - {1, 2, 3, 4, p, n } (Assumes 4 Spaces Max per Display)
      shift + lalt - 1 : SPACES=($(yabai -m query --displays --display | jq '.spaces[]')) && [[ -n $SPACES[1] ]] \
                        && yabai -m window --space $SPACES[1]

      shift + lalt - 2 : SPACES=($(yabai -m query --displays --display | jq '.spaces[]')) && [[ -n $SPACES[2] ]] \
                        && yabai -m window --space $SPACES[2]

      shift + lalt - 3 : SPACES=($(yabai -m query --displays --display | jq '.spaces[]')) && [[ -n $SPACES[3] ]] \
                        && yabai -m window --space $SPACES[3]

      shift + lalt - 4 : SPACES=($(yabai -m query --displays --display | jq '.spaces[]')) && [[ -n $SPACES[4] ]] \
                        && yabai -m window --space $SPACES[4]

      shift + lalt - p : yabai -m window --space prev && yabai -m space --focus prev
      shift + lalt - n : yabai -m window --space next && yabai -m space --focus next

      # Mirror Space on X and Y Axis: shift + lalt - {x, y}
      shift + lalt - x : yabai -m space --mirror x-axis
      shift + lalt - y : yabai -m space --mirror y-axis

      ## Stacks (shift + ctrl - ...)
      # Add the active window to the window or stack to the {direction}: shift + ctrl - {j, k, l, ö}
      shift + ctrl - j    : yabai -m window  west --stack $(yabai -m query --windows --window | jq -r '.id')
      shift + ctrl - k    : yabai -m window south --stack $(yabai -m query --windows --window | jq -r '.id')
      shift + ctrl - l    : yabai -m window north --stack $(yabai -m query --windows --window | jq -r '.id')
      shift + ctrl - 0x29 : yabai -m window  east --stack $(yabai -m query --windows --window | jq -r '.id')

      # Stack Navigation: shift + ctrl - {n, p}
      shift + ctrl - n : yabai -m window --focus stack.next
      shift + ctrl - p : yabai -m window --focus stack.prev

      ## Resize (ctrl + lalt - ...)
      # Resize windows: ctrl + lalt - {j, k, l, ö}
      ctrl + lalt - j    : yabai -m window --resize right:-100:0 || yabai -m window --resize left:-100:0
      ctrl + lalt - k    : yabai -m window --resize bottom:0:100 || yabai -m window --resize top:0:100
      ctrl + lalt - l    : yabai -m window --resize bottom:0:-100 || yabai -m window --resize top:0:-100
      ctrl + lalt - 0x29 : yabai -m window --resize right:100:0 || yabai -m window --resize left:100:0

      # Equalize size of windows: ctrl + lalt - e
      ctrl + lalt - e : yabai -m space --balance

      # Enable / Disable gaps in current workspace: ctrl + lalt - g
      ctrl + lalt - g : yabai -m space --toggle padding; yabai -m space --toggle gap

      ## Insertion (shift + ctrl + lalt - ...)
      # Set insertion point for focused container: shift + ctrl + lalt - {j, k, l, ö, s}
      shift + ctrl + lalt - j : yabai -m window --insert west
      shift + ctrl + lalt - k : yabai -m window --insert south
      shift + ctrl + lalt - l : yabai -m window --insert north
      shift + ctrl + lalt - 0x29 : yabai -m window --insert east
      shift + ctrl + lalt - s : yabai -m window --insert stack

      # New window in hor./ vert. splits for all applications with yabai
      lalt - s : yabai -m window --insert east;  skhd -k "cmd - n"
      lalt - v : yabai -m window --insert south; skhd -k "cmd - n"

      # Toggle sketchybar
      shift + lalt - space : sketchybar --bar hidden=toggle
      shift + lalt - r :  sketchybar --reload
    '';
  };

  services.jankyborders = {
    enable = true;
    package = pkgs.jankyborders;
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };

    brews = pkgs.callPackage ./brews.nix {};
    casks = pkgs.callPackage ./casks.nix {};
    # onActivation.cleanup = "uninstall";

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
      "xcode" = 497799835;
      "Microsoft Remote Desktop" = 1295203466;
    };
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, lib, ... }:{
      home = {
        enableNixpkgsReleaseCheck = false;
        packages = pkgs.callPackage ./packages.nix {};
        file = lib.mkMerge [
          sharedFiles
          additionalFiles
        ];

        stateVersion = "23.11";
      };
      programs = {

      } // import ../shared/home-manager.nix { inherit config pkgs lib; };

      # Marked broken Oct 20, 2022 check later to remove this
      # https://github.com/nix-community/home-manager/issues/3344
      manual.manpages.enable = false;
    };
  };

  # Fully declarative dock using the latest from Nix Store
  local.dock.enable = true;
  local.dock.entries = [
    { path = "${pkgs.kitty}/Applications/Kitty.app/"; }
    {
      path = "${config.users.users.${user}.home}/.local/share/downloads";
      section = "others";
      options = "--sort name --view grid --display stack";
    }
  ];

}
