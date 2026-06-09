# Troubleshooting

Notes on issues that have hit this nix-darwin config and how to diagnose / fix them.

## launchd: services stuck with `last exit code = 78` (EX_CONFIG)

### Symptoms

`launchctl list | grep nixos` shows non-zero exit codes (commonly `78`) for one
or more of `org.nixos.yabai`, `org.nixos.skhd`, `org.nixos.sketchybar`,
`org.nixos.jankyborders`. The service shows `state = spawn scheduled` in
`launchctl print` but never actually runs — it's in launchd's penalty box,
because it crashed enough times in a row that launchd gave up retrying.

### Diagnose

```sh
# Per-service status
for s in yabai skhd sketchybar jankyborders; do
  echo "=== $s ==="
  launchctl print "gui/$(id -u)/org.nixos.$s" 2>&1 \
    | grep -E "state =|last exit code|program ="
done

# Check whether processes are actually alive
pgrep -lf 'yabai|skhd|sketchybar|borders'
```

The launchd-spawned plists have no `StandardErrorPath`, so to see the real
error, run the binary in the foreground from a terminal:

```sh
# Boot the service out first so it doesn't fight you for the mach port
launchctl bootout "gui/$(id -u)/org.nixos.sketchybar"
cd ~/.config/sketchybar
/nix/store/<hash>-sketchybar-*/bin/sketchybar       # ctrl-c to stop
```

### Recover from the penalty box

Once the underlying cause is fixed, `launchctl kickstart -k` alone is often
**not enough** — the service has to be fully unloaded and reloaded:

```sh
S=org.nixos.sketchybar       # or yabai, skhd, jankyborders
launchctl bootout    "gui/$(id -u)/$S"
launchctl bootstrap  "gui/$(id -u)" "$HOME/Library/LaunchAgents/$S.plist"
```

### Known config bugs that produced this

#### yabai — `extraConfig` nested inside `config = { ... }`

**Wrong:**

```nix
services.yabai = {
  enable = true;
  enableScriptingAddition = true;
  config = {
    extraConfig = builtins.readFile ./config/yabai/yabairc;
  };
};
```

nix-darwin walks `services.yabai.config` as an attrset and emits
`yabai -m config <key> <value>` for each entry. `extraConfig` is not a yabai
config key, so the generated `yabairc` starts with:

```
yabai -m config extraConfig #!/usr/bin/env sh
...
```

yabai then prints `unknown command 'extraConfig'` and the launcher exits 78.

**Right** — `extraConfig` is a top-level option of `services.yabai`:

```nix
services.yabai = {
  enable = true;
  enableScriptingAddition = true;
  extraConfig = builtins.readFile ./config/yabai/yabairc;
};
```

#### sketchybar — relative `package.path` in the Lua rc

The Lua sketchybarrc used `./?.lua;./?/init.lua` which assumes the
working directory is `~/.config/sketchybar`. Under launchd the CWD is `/`,
so `require("helpers")` fails. Use an absolute path derived from `$HOME`:

```lua
local config_dir = os.getenv("HOME") .. "/.config/sketchybar"
package.path = config_dir .. "/?.lua;" .. config_dir .. "/?/init.lua;" .. package.path
```

(Defined in `modules/darwin/files.nix`.)

#### sketchybar — `helpers/init.lua` used `$USER`

`os.getenv("USER")` isn't guaranteed in launchd's env. Use `HOME` instead, and
drop the `os.execute("(cd helpers && make)")` line — the helper binaries are
already built and symlinked by `files.nix` and `sketchybar/c-binaries.nix`,
so running `make` here is at best redundant and at worst a build error.

```lua
package.cpath = package.cpath .. ";" .. os.getenv("HOME") .. "/.local/share/sketchybar_lua/?.so"
```

#### skhd / jankyborders

No source bugs found — both were just collateral damage from the penalty box.
After yabai/sketchybar were fixed and the launchd state was reset with
`bootout` + `bootstrap`, both came up clean.

## TCC (Accessibility / Screen Recording) and nix store paths

yabai, sketchybar, and jankyborders all need macOS Accessibility (and yabai
additionally Screen Recording) permission. TCC grants are keyed to the
**exact binary path**, so a `darwin-rebuild` that bumps a package version
invalidates the previous grant and the service will start exiting 78 again.

If this turns into a recurring problem, the usual workaround is to symlink
the binary to a stable path via `system.activationScripts` and grant TCC
permission to that stable path instead of the `/nix/store/...` one.

## Useful one-liners

```sh
# Show the generated yabairc that nix-darwin built
launchctl print "gui/$(id -u)/org.nixos.yabai" | grep -E "program|arguments" -A2

# Tail logs for one of the bar/wm services
log stream --process sketchybar --level=debug
log stream --process yabai      --level=debug
log stream --process borders    --level=debug

# Reset all four services in one go
for S in yabai skhd sketchybar jankyborders; do
  launchctl bootout   "gui/$(id -u)/org.nixos.$S" 2>/dev/null
  launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/org.nixos.$S.plist"
done
```
