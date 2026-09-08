{
  description = "Schni's Nix Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };
    # `brew bundle` ships inside brew itself since 2025; the separate
    # homebrew/homebrew-bundle tap is archived and no longer needed.
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-steipete-tap = {
      url = "github:steipete/homebrew-tap";
      flake = false;
    };
    # Private tap (Adversary-GmbH/noTime) -> fetched over SSH, needs the deploy key of the host
    homebrew-notime-tap = {
      url = "git+ssh://git@github.com/Adversary-GmbH/noTime.git";
      flake = false;
    };
  };

  outputs = { self, darwin, nix-homebrew, homebrew-core, homebrew-cask, homebrew-steipete-tap, homebrew-notime-tap, home-manager, nixpkgs, ... } @inputs:
    let
      user = "schni";
      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      # Only Apple Silicon Macs are managed here.
      darwinSystems = [ "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
      devShell = system: let pkgs = nixpkgs.legacyPackages.${system}; in {
        default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [ bashInteractive git ];
        };
      };
      mkApp = scriptName: system: {
        type = "app";
        program = "${(nixpkgs.legacyPackages.${system}.writeScriptBin scriptName ''
          #!/usr/bin/env bash
          PATH=${nixpkgs.legacyPackages.${system}.git}/bin:$PATH
          echo "Running ${scriptName} for ${system}"
          exec ${self}/apps/${system}/${scriptName} "$@"
        '')}/bin/${scriptName}";
      };
      # Every executable in apps/<system>/ becomes `nix run .#<name>`.
      mkApps = system:
        nixpkgs.lib.genAttrs
          (builtins.attrNames (builtins.readDir (./apps + "/${system}")))
          (scriptName: mkApp scriptName system);
      mkDarwin = system: hostModules: darwin.lib.darwinSystem {
        inherit system;
        specialArgs = inputs;
        modules = [
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              inherit user;
              enable = true;
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "steipete/homebrew-tap" = homebrew-steipete-tap;
              };
              mutableTaps = false;
              autoMigrate = true;
            };
          }
        ] ++ hostModules;
      };
    in
    {
      devShells = forAllSystems devShell;
      apps = forAllSystems mkApps;

      darwinConfigurations = {
        # Daily driver. Keyed by system so `nix run .#build-switch` finds it
        # without FLAKE_HOST.
        aarch64-darwin = mkDarwin "aarch64-darwin" [ ./hosts/darwin ];

        # Pentest MacBook (Apple Silicon).
        # Switch with: FLAKE_HOST=pentest nix run .#build-switch
        pentest = mkDarwin "aarch64-darwin" [
          ./hosts/pentest
          # Private tap (Adversary-GmbH/noTime), only tapped on the pentest host.
          { nix-homebrew.taps."adversary-gmbh/homebrew-notime" = homebrew-notime-tap; }
        ];
      };

      wslConfigurations = nixpkgs.lib.genAttrs linuxSystems (system:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = inputs;
        modules = [
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = import ./modules/wsl/home-manager.nix;
            };
          }
          ./hosts/wsl
        ];
      }
    );
  };
}
