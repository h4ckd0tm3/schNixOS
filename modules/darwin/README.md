
## Layout
```
.
├── config             # yabai, skhd and sketchybar files (not Nix)
├── dock               # MacOS dock module (options + activation)
├── sketchybar         # Derivations for the C helpers under config/sketchybar
├── brews.nix          # List of homebrew formulae
├── casks.nix          # List of homebrew casks
├── common.nix         # System-level config shared by every Mac (nix, defaults)
├── desktop-base.nix   # Window manager / status bar / toolchain packages, every Mac
├── files.nix          # Non-Nix, static configuration files (now immutable!)
├── home-base.nix      # User-level plumbing shared by every Mac (account, services,
│                      #   homebrew policy, home-manager wiring, dock)
├── home-manager.nix   # Daily driver: yabai/skhd config and its own lists
├── packages.nix       # List of packages to install for the daily driver
```

`casks.nix`, `brews.nix` and `packages.nix` here are the **daily driver's** lists
only. The pentest host keeps its own copies — see below.

## Hosts

`hosts/darwin` is the daily driver, built as `darwinConfigurations.aarch64-darwin`.

The pentest MacBook ("kusanagi") is a separate, standalone host: `hosts/pentest`
plus `modules/pentest`, mirroring this layout. It imports the shared
infrastructure from here — `common.nix`, `home-base.nix`, `desktop-base.nix`,
the dock module, `files.nix` and the raw files under `config/` — but never the
daily driver's `home-manager.nix` or its lists. See `modules/pentest/README.md`.

**So `brews.nix`, `casks.nix` and `packages.nix` in this directory are the daily
driver's lists only.** An app you want on both machines has to be added to both.
