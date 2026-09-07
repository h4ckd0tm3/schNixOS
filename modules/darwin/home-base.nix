{ config, pkgs, lib, catppuccin, ... }:

# User-level plumbing shared by every macOS host: the user account, the
# sketchybar/jankyborders services, homebrew activation policy, the
# home-manager wiring (files, ai-skills activation, shared programs, theme)
# and the dock. Hosts add the yabai/skhd config and their own package,
# brew, cask and App Store lists.

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
    name = user;
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  # Services ------------------------------------------------------------------

  services.sketchybar = {
    enable = true;
    # The agent's PATH is only this list plus environment.systemPath; the
    # volume and media widgets shell out to these.
    extraPackages = with pkgs; [ switchaudio-osx nowplaying-cli jq ];
  };

  services.jankyborders = {
    enable = true;
    style = "round";
    width = 4.0;
    hidpi = false;
    active_color = "0xaae2e2e3";
    inactive_color = "0xaa414550";
    background_color = "0x302c2e34";
  };

  # skhd runs hotkey commands through $SHELL; without this launchd leaves SHELL
  # unset and skhd falls back to /bin/bash, which breaks the zsh array syntax
  # ($SPACES[1]) used by the space focus/move bindings.
  launchd.user.agents.skhd.serviceConfig.EnvironmentVariables.SHELL = "${pkgs.zsh}/bin/zsh";

  # Homebrew ------------------------------------------------------------------

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };

    # nix-homebrew owns the taps (mutableTaps = false in flake.nix), so this
    # module's generated Brewfile lists none of them. Combined with the cleanup
    # above that means every `brew bundle --force-cleanup` during activation
    # tries to untap homebrew/cask -- which either fails against the read-only
    # nix-homebrew tap dirs or leaves brew unable to resolve a single cask
    # afterwards. Mirroring nix-homebrew's tap set into the Brewfile makes
    # cleanup treat them as declared and leave them alone.
    taps = builtins.attrNames config.nix-homebrew.taps;
  };

  # home-manager --------------------------------------------------------------

  home-manager = {
    useGlobalPkgs = true;
    # Home packages go to /etc/profiles/per-user/<user>, which nix-darwin puts
    # on environment.systemPath, so launchd agents can reach them too.
    useUserPackages = true;
    backupFileExtension = "hm-bak";

    users.${user} = { pkgs, config, lib, ... }:
      let
        # AI-skill CLIs + their Claude Code setup steps. Add new tools there.
        aiSkills = pkgs.callPackage ../shared/ai-skills.nix { };

        # Emit a PATH-guarded, dry-run-aware shell snippet for one command.
        guard = bin: run: ''
          if command -v ${bin} >/dev/null 2>&1; then
            $DRY_RUN_CMD ${run}
          else
            echo "${bin} not found in PATH; skipping: ${run}"
          fi
        '';
      in
      {
        home = {
          enableNixpkgsReleaseCheck = false;
          file = additionalFiles;

          stateVersion = "23.11";

          # Install pinned global npm CLIs, then run each tool's Claude Code
          # setup. Everything is data-driven from ../shared/ai-skills.nix.
          activation.aiSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] (
            # /opt/homebrew/bin for brew-installed CLIs (node/npx); pkgs.git so the
            # `skills` CLI's internal `spawn git` resolves (else: spawn git ENOENT).
            ''export PATH="/opt/homebrew/bin:${lib.makeBinPath [ pkgs.git ]}:$PATH"''
            + lib.optionalString (aiSkills.globals != [ ])
              ("\n" + guard "npm" "npm install -g ${lib.concatStringsSep " " aiSkills.globals}")
            + lib.concatMapStrings (s: "\n" + guard s.bin s.run) aiSkills.setup
          );
        };

        programs = import ../shared/home-manager.nix { inherit config pkgs lib; };

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
