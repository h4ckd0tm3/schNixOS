## Shared
Config that every host in this repo uses, macOS or Linux.

`default.nix` is imported by each host; `home-manager.nix` and `packages.nix`
are pulled in by the per-platform home-manager modules.

## Layout
```
.
├── config             # Config files not written in Nix (p10k)
├── ai-skills.nix      # Data: npm CLIs and Claude Code setup steps run at activation
├── default.nix        # nixpkgs config and how overlays/ is loaded
├── home-manager.nix   # Shared programs: zsh, git, kitty, fzf, ssh, direnv, ...
├── packages.nix       # Cross-platform CLI packages
```
