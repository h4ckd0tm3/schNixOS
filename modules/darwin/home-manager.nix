{ config, pkgs, lib, home-manager, catppuccin, ... }:

let
  user = "schni";
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
  };

  services.yabai = {
    enable = true;
    enableScriptingAddition = true;
    extraConfig =
      builtins.readFile ./config/yabai/yabairc
      + builtins.readFile ./config/yabai/rules;
  };

  services.skhd = {
    enable = true;
    # https://github.com/koekeishiya/skhd/blob/master/examples/skhdrc
    # https://github.com/koekeishiya/skhd/issues/1
    # Split so SIP-on hosts can swap only the space bindings (hosts/pentest).
    skhdConfig =
      builtins.readFile ./config/skhd/skhdrc-spaces
      + builtins.readFile ./config/skhd/skhdrc-common;
  };

  # skhd runs hotkey commands through $SHELL; without this launchd leaves SHELL
  # unset and skhd falls back to /bin/bash, which breaks the zsh array syntax
  # ($SPACES[1]) used by the space focus/move bindings above.
  launchd.user.agents.skhd.serviceConfig.EnvironmentVariables.SHELL = "${pkgs.zsh}/bin/zsh";

  services.jankyborders = {
    enable = true;
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };

    brews = pkgs.callPackage ./brews.nix {};
    casks = pkgs.callPackage ./casks.nix {};
    onActivation.cleanup = "uninstall";

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
      "Windows App" = 1295203466;
    };
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, lib, ... }:
      let
        # AI-skill CLIs + their Claude Code setup steps. Add new tools here.
        aiSkills = pkgs.callPackage ../shared/ai-skills.nix {};

        # Emit a PATH-guarded, dry-run-aware shell snippet for one command.
        guard = bin: run: ''
          if command -v ${bin} >/dev/null 2>&1; then
            $DRY_RUN_CMD ${run}
          else
            echo "${bin} not found in PATH; skipping: ${run}"
          fi
        '';
      in {
      home = {
        enableNixpkgsReleaseCheck = false;
        packages = pkgs.callPackage ./packages.nix {};
        file = additionalFiles;

        stateVersion = "23.11";

        # Install pinned global npm CLIs, then run each tool's Claude Code setup.
        # Everything is data-driven from ../shared/ai-skills.nix — add tools there.
        activation.aiSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] (
          # /opt/homebrew/bin for brew-installed CLIs (node/npx); pkgs.git so the
          # `skills` CLI's internal `spawn git` resolves (else: spawn git ENOENT).
          ''export PATH="/opt/homebrew/bin:${lib.makeBinPath [ pkgs.git ]}:$PATH"''
          + lib.optionalString (aiSkills.globals != [])
              ("\n" + guard "npm" "npm install -g ${lib.concatStringsSep " " aiSkills.globals}")
          + lib.concatMapStrings (s: "\n" + guard s.bin s.run) aiSkills.setup
        );
      };
      programs = {

      } // import ../shared/home-manager.nix { inherit config pkgs lib; };

      manual.manpages.enable = false;
      catppuccin.flavor = "mocha";
      catppuccin.autoEnable = true;
      catppuccin.enable = true;
      imports = [
        catppuccin.homeModules.catppuccin
      ];
    };
  };

  # Fully declarative dock using the latest from Nix Store
  local.dock.enable = true;
  local.dock.username = user;
  local.dock.entries = [
    { path = "${pkgs.kitty}/Applications/Kitty.app/"; }
    {
      path = "${config.users.users.${user}.home}/.local/share/downloads";
      section = "others";
      options = "--sort name --view grid --display stack";
    }
  ];

}
