
## Layout
```
.
├── dock               # MacOS dock configuration
├── casks.nix          # List of homebrew casks
├── default.nix        # Defines module, system-level config
├── files.nix          # Non-Nix, static configuration files (now immutable!)
├── home-manager.nix   # Defines user programs
├── packages.nix       # List of packages to install for MacOS
├── pentest            # Overlay for the pentest host (see below)
```

## Hosts

`hosts/darwin` is the daily driver and is built as `darwinConfigurations.<system>`.
The pentest MacBook ("kusanagi") is its own host at `hosts/pentest`, which imports
that same base plus the `modules/darwin/pentest` tooling overlay, and is built as
`darwinConfigurations.pentest`:

```
FLAKE_HOST=pentest nix run .#build-switch
```

The overlay only states tooling differences — extra packages, extra casks, a few
personal casks removed. Host identity (hostname, Touch ID sudo, lock policy,
wallpaper) lives in `hosts/pentest`. Everything else (window manager, shell, git,
macOS defaults) is inherited unchanged.
