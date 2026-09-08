{ user, config, pkgs, ... }:

let
  xdg_configHome = "${config.users.users.${user}.home}/.config";
  xdg_dataHome   = "${config.users.users.${user}.home}/.local/share";
  binaries = import ./sketchybar/c-binaries.nix {inherit pkgs;};
in
{
  "${xdg_configHome}/sketchybar" = {
    source = ./config/sketchybar;
    recursive = true;
    onChange = "${pkgs.sketchybar}/bin/sketchybar --reload";
  };

  "${xdg_dataHome}/sketchybar_lua/sketchybar.so" = {
    source = "${pkgs.sbarlua}/lib/lua/5.5/sketchybar.so";
    onChange = "${pkgs.sketchybar}/bin/sketchybar --reload";
  };
  
  "${xdg_configHome}/sketchybar/sketchybarrc" = {
    text = ''
      #!/usr/bin/env ${pkgs.lua55Packages.lua}/bin/lua
      local config_dir = os.getenv("HOME") .. "/.config/sketchybar"
      package.path = config_dir .. "/?.lua;" .. config_dir .. "/?/init.lua;" .. package.path
      -- `sketchybar --reload` leaves the previous config's Lua event loop behind; kill older
      -- sketchybarrc processes (pid < ours, $PPID of the sh spawned by os.execute). Comparing
      -- pids instead of "not me" matters: back-to-back reloads must not kill each other.
      os.execute([[for p in $(pgrep -f "lua .*/sketchybar/sketchybarrc"); do [ "$p" -lt "$PPID" ] && kill "$p"; done]])
      -- Load the sketchybar-package and prepare the helper binaries
      require("helpers")
      require("init")
    '';
    executable = true;
    onChange = "${pkgs.sketchybar}/bin/sketchybar --reload";
  };

  "${xdg_configHome}/sketchybar/helpers/event_providers/cpu_load/bin/cpu_load".source = "${binaries.cpuLoadBinary}/bin/cpu_load";
  "${xdg_configHome}/sketchybar/helpers/event_providers/network_load/bin/network_load".source = "${binaries.networkLoadBinary}/bin/network_load";
  "${xdg_configHome}/sketchybar/helpers/menus/bin/menus".source = "${binaries.menusBinary}/bin/menus";
  "${xdg_configHome}/sketchybar/helpers/wifi_ssid/bin/wifi_ssid.app".source = "${binaries.wifiSsidApp}/wifi_ssid.app";

  ".config/kitty/macos-launch-services-cmdline" = {
    text = "--listen-on unix:/tmp/mykitty.sock";
  };
}