{ user, config, pkgs, ... }:

let
  xdg_configHome = "${config.users.users.${user}.home}/.config";
  xdg_dataHome   = "${config.users.users.${user}.home}/.local/share";
  xdg_stateHome  = "${config.users.users.${user}.home}/.local/state"; 
  binaries = import ./sketchybar/c-binaries.nix {inherit pkgs;};
in
{
  "${xdg_configHome}/sketchybar" = {
    source = ./config/sketchybar;
    recursive = true;
    onChange = "${pkgs.sketchybar}/bin/sketchybar --reload";
  };

  "${xdg_dataHome}/sketchybar_lua/sketchybar.so" = {
    source = "${pkgs.sbar-lua}/lib/sketchybar.so";
    onChange = "${pkgs.sketchybar}/bin/sketchybar --reload";
  };
  
  "${xdg_configHome}/sketchybar/sketchybarrc" = {
    text = ''
      #!/usr/bin/env ${pkgs.lua54Packages.lua}/bin/lua
      package.path = "./?.lua;./?/init.lua;" .. package.path
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
}