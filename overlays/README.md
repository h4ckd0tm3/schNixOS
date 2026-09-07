# Overlays

Every `*.nix` file (or directory with a `default.nix`) in here is loaded
automatically by `modules/shared/default.nix` and applied to **every host**,
so an overlay written for one machine still evaluates on the others. Keep
them lazy (only touch the package you override) and delete them once
upstream catches up — each file's header says when.

Common uses:
* Applying patches
* Downloading different versions of files (locking to a version or trying a fork)
* Workarounds and stuff I need to run temporarily
