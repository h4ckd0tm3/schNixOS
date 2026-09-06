
## Layout
```
.
├── dock               # MacOS dock configuration
├── brews.nix          # List of homebrew formulae
├── casks.nix          # List of homebrew casks
├── default.nix        # Defines module, system-level config
├── files.nix          # Non-Nix, static configuration files (now immutable!)
├── home-manager.nix   # Defines user programs
├── packages.nix       # List of packages to install for MacOS
```

`casks.nix`, `brews.nix` and `packages.nix` here are the **daily driver's** lists
only. The pentest host keeps its own copies — see below.

## Hosts

`hosts/darwin` is the daily driver, built as `darwinConfigurations.<system>`.

The pentest MacBook ("kusanagi") is a separate, standalone host: `hosts/pentest`
plus `modules/pentest`, mirroring this layout. It does not import anything from
here except the dock module, `files.nix` and the raw files under `config/` — see
`modules/pentest/README.md`.

**So `brews.nix`, `casks.nix` and `packages.nix` in this directory are the daily
driver's lists only.** An app you want on both machines has to be added to both.
