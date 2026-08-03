
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
The pentest MacBook layers `modules/darwin/pentest` on top of that same base and is
built as `darwinConfigurations.pentest`:

```
FLAKE_HOST=pentest nix run .#build-switch
```

The overlay only states differences — extra tooling, extra casks, a few personal
casks removed, Touch ID sudo, and its own wallpaper. Everything else (window
manager, shell, git, macOS defaults) is inherited unchanged.
