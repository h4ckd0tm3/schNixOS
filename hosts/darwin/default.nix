{ config, pkgs, ... }:

let user = "schni"; in

{
  imports = [
    ../../modules/darwin/home-manager.nix
    ../../modules/shared
  ];

  services.nix-daemon.enable = true;

  nix = {
    package = pkgs.nix;
    settings = {
      trusted-users = [ "@admin" "${user}" ];
      substituters = [ "https://nix-community.cachix.org" "https://cache.nixos.org" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
    };

    gc = {
      user = "root";
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  system.checks.verifyNixPath = false;

  environment.systemPackages = with pkgs; [
  ] ++ (import ../../modules/shared/packages.nix { inherit pkgs; });

  system = {
    stateVersion = 4;

    defaults = {
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

      CustomUserPreferences ={
        NSGlobalDomain = {
          # Add a context menu item for showing the Web Inspector in web views
          WebKitDeveloperExtras = true;
        };

        "com.apple.NetworkBrowser" = {
          BrowseAllInterfaces = 1;
        };

        #"com.apple.Safari" = {
        #  AutoOpenSafeDownloads = false;
        #  IncludeDevelopMenu = true;
        #  WebKitDeveloperExtrasEnabledPreferenceKey = true;
        #  "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;
        #};

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

  system.activationScripts.postUserActivation.text = ''
    # activateSettings -u will reload the settings from the database and apply them to the current session,
    # so we do not need to logout and login again to make the changes take effect.
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

    /usr/local/bin/desktoppr all "/Users/schni/nixos-config/hosts/wallpapers/arle.jpeg"
  '';
}
