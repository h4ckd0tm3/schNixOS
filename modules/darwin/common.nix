{ config, lib, pkgs, ... }:

# System-level config shared by every macOS host (hosts/darwin, hosts/pentest):
# nix daemon settings, GC/optimise schedule, fonts, macOS defaults and the
# post-activation script. Hosts add only what is genuinely theirs (hostname,
# wallpaper).

let user = "schni"; in

{
  options.local.wallpaper = lib.mkOption {
    type = lib.types.path;
    description = "Image applied to every display by desktoppr after activation.";
  };

  config = {
    # Constant sudo on both machines. Touch ID beats retyping the password.
    security.pam.services.sudo_local.touchIdAuth = true;

    nix = {
      settings = {
        trusted-users = [ "@admin" user ];
        experimental-features = [ "nix-command" "flakes" ];
        # nix-darwin appends cache.nixos.org and its key itself.
        substituters = [ "https://nix-community.cachix.org" ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };

      gc = {
        automatic = true;
        interval = { Weekday = 0; Hour = 2; Minute = 0; };
        options = "--delete-older-than 30d";
      };

      # auto-optimise-store is unsupported on macOS; this is the darwin way.
      optimise = {
        automatic = true;
        interval = { Weekday = 0; Hour = 3; Minute = 0; };
      };
    };

    system.checks.verifyNixPath = false;

    system.primaryUser = user;

    fonts.packages = [ pkgs.berkeley-mono ];

    system = {
      stateVersion = 5;

      defaults = {
        # Require the password immediately on lock, no grace period.
        screensaver = {
          askForPassword = true;
          askForPasswordDelay = 0;
        };

        NSGlobalDomain = {
          AppleShowAllExtensions = true;
          ApplePressAndHoldEnabled = false;

          _HIHideMenuBar = true;

          NSAutomaticWindowAnimationsEnabled = false;
          NSAutomaticSpellingCorrectionEnabled = false;

          KeyRepeat = 2; # Values: 120, 90, 60, 30, 12, 6, 2
          InitialKeyRepeat = 15; # Values: 120, 94, 68, 35, 25, 15

          "com.apple.swipescrolldirection" = true;
        };

        dock = {
          autohide = true;
          orientation = "right";
          tilesize = 36;
          static-only = true;
          mru-spaces = false;
        };

        CustomUserPreferences = {
          NSGlobalDomain = {
            # Add a context menu item for showing the Web Inspector in web views
            WebKitDeveloperExtras = true;
          };

          "com.apple.NetworkBrowser" = {
            BrowseAllInterfaces = 1;
          };

          "com.apple.finder" = {
            AppleShowAllFiles = true;
            DisableAllAnimations = true;
            FXDefaultSearchScope = "SCcf";
            FXEnableExtensionChangeWarning = false;
            FXPreferredViewStyle = "Nlsv";
            ShowExternalHardDrivesOnDesktop = false;
            ShowHardDrivesOnDesktop = false;
            ShowMountedServersOnDesktop = false;
            ShowRemovableMediaOnDesktop = false;
            ShowStatusBar = false;
            _FXShowPosixPathInTitle = true;
          };

          "com.apple.spaces" = {
            spans-displays = false;
          };

          "com.apple.screencapture" = {
            location = "~/Desktop";
            disable-shadow = true;
            type = "png";
          };

          "com.apple.desktopservices" = {
            # Avoid creating .DS_Store files on network or USB volumes
            DSDontWriteNetworkStores = true;
            DSDontWriteUSBStores = true;
          };

          "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
          "com.apple.LaunchServices".LSQuarantine = false;
        };
      };
    };

    system.activationScripts.postActivation.text = ''
      # activateSettings -u will reload the settings from the database and apply them to the current session,
      # so we do not need to logout and login again to make the changes take effect.
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

      # Guarded: on a freshly provisioned machine the cask is not installed yet,
      # and an unguarded call aborts the whole activation.
      if [ -x /usr/local/bin/desktoppr ]; then
        /usr/local/bin/desktoppr all "${config.local.wallpaper}"
      fi
    '';
  };
}
