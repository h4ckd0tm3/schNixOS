{ config, pkgs, lib, ... }:

let name = "Marcel Schnideritsch";
    user = "schni";
    email = "marcel@schnideritsch.at"; in
{
  # Shared shell configuration
  zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8"
      "--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc"
      "--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
      "--color=selected-bg:#45475a"
      "--multi"
    ];
  };

  bat = {
    enable = true;
  };

  zsh = {
    enable = true;
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = lib.cleanSource ./config;
        file = "p10k.zsh";
      }
    ];
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
      ];
      extraConfig = ''
        ENABLE_CORRECTION="true"
      '';
    };
    initContent = ''
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
      fi

        alias nani='echo "\033[0;31mOmae wa mou shindeiru" && sleep 1.5s && nano'
        alias c='clear'
        alias fuck='sudo $(fc -ln -1)'
        alias x='exit'

        alias grep='grep --color=auto'
        alias fgrep='grep -F --color=auto'
        alias egrep='grep -E --color=auto'
        alias diff='diff --color=auto'

        alias cat='bat'
        alias ssh="TERM=xterm-256color ssh"

        command -v lsd &> /dev/null && alias ls='lsd --group-dirs first'
        
        eval "$(navi widget zsh)"

        function mkcd() {
                mkdir -p "$1" && cd "$1"
        }

        function transfer() {
            if [ $# -eq 0 ]; then
                echo "No arguments specified.\nUsage:\n transfer <file|directory>\n ... | transfer <file_name>" >&2
                return 1
            fi
            if tty -s; then
                file="$1"
                file_name=$(basename "$file")
                if [ ! -e "$file" ]; then
                    echo "$file: No such file or directory" >&2
                    return 1
                fi
                if [ -d "$file" ]; then
                    file_name="$file_name.zip"
                    ,
                    (cd "$file" && zip -r -q - .) | curl -u zippy:zippy --progress-bar --upload-file "-" "https://tr.vuln.at/$file_name" | tee /dev/null | pbcopy,
                else
                    cat "$file" | curl -u zippy:zippy --progress-bar --upload-file "-" "https://tr.vuln.at/$file_name" | tee /dev/null | pbcopy
                fi
            else
                file_name=$1
                curl -u zippy:zippy --progress-bar --upload-file "-" "https://tr.vuln.at/$file_name" | tee /dev/null | pbcopy
            fi
        }

        export XDG_CONFIG_HOME="$HOME/.config"

        export PATH="$HOME/Documents/flutter/bin:$HOME/.local/bin:$PATH"

        # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      '';
  };
    
  kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    font.name = "Hack Nerd Font Mono";
    font.size = 15;
    themeFile = "Catppuccin-Mocha";
    keybindings = {
      "cmd+1" = "goto_tab 1";
      "cmd+2" = "goto_tab 2";
      "cmd+3" = "goto_tab 3";
      "cmd+4" = "goto_tab 4";
      "cmd+5" = "goto_tab 5";
      "cmd+6" = "goto_tab 6";
      "cmd+7" = "goto_tab 7";
      "cmd+8" = "goto_tab 8";
      "cmd+9" = "goto_tab 9";
      "cmd+0" = "goto_tab 10";
      "cmd+t" = "launch --type=tab --cwd=current";
      "cmd+n" = "launch --type=os-window --cwd=current";
      # jump to beginning and end of word
      "alt+left"  = "send_text all \\x1b\\x62";
      "alt+right" = "send_text all \\x1b\\x66";
      # jump to beginning and end of line
      "cmd+left"  = "send_text all \\x01";
      "cmd+right" = "send_text all \\x05";
    };
    settings = {
      allow_remote_control = "yes";
      bold_font        = "Hack Nerd Font Mono Bold";
      italic_font      = "Hack Nerd Font Mono Italic";
      bold_italic_font = "Hack Nerd Font Mono Bold Italic";
      hide_window_decorations = "titlebar-only";
      window_margin_width = 4;
      cursor_blink_interval = 0;
      macos_quit_when_last_window_closed = "no";
      macos_colorspace = "default";
      macos_show_window_title_in = "window";
      repaint_delay = 8;
      input_delay = 1;
      resize_draw_strategy = "blank";
      remember_window_size = "no";
      confirm_os_window_close = -1;

      tab_bar_min_tabs = 1;
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_title_template = "{fmt.fg.red}{bell_symbol}{fmt.fg.tab} {index}: {title} {activity_symbol}";

      # OS Window titlebar colors
      wayland_titlebar_color = "system";
      macos_titlebar_color = "system";
    };
    extraConfig = ''
      resize_debounce_time 0.001
      background_opacity 0.9
      symbol_map U+F0001-U+F1af0 Hack Nerd Font
      symbol_map U+F8FF,U+100000-U+1018C7 SF Pro
      active_tab_font_style bold
      inactive_tab_font_style normal
    '';
  };

  git = {
    enable = true;
    ignores = [ "*.swp" ];
    lfs = {
      enable = true;
    };
    signing.format = null;
    settings = {
      init.defaultBranch = "main";
      core = {
	    editor = "vim";
        autocrlf = "input";
      };
      user = {
        name = name;
        email = email;
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFtij4eh2WgT5OLTDzjGSixe+JEx9UUhh4dFIKdojghL";
      };
      pull.rebase = true;
      rebase.autoStash = true;
      gpg = {
        format = "ssh";
      };
      "gpg \"ssh\"" = {
        program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };
      commit = {
        gpgsign = true;
      };
    };
  };

  direnv.enable = true;

  ssh = {
    enable = true;
    enableDefaultConfig = false;
    extraConfig = ''
      Host *
        IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    '';
    includes = [
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
        "/home/${user}/.ssh/config_external"
      )
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
        "/Users/${user}/.ssh/config_external"
      )
    ];
    settings = {
      "*" = {
        # Set the default values we want to keep
        SendEnv = [ "LANG" "LC_*" ];
        HashKnownHosts = true;
      };

      "nyx" = {
        User = "root";
        HostName = "149.154.152.151";
      };

      "cloudia" = {
        User = "schni";
        HostName = "45.142.176.14";
      };

      "allinkl" = {
        User = "ssh-w012e3e5";
        HostName = "85.13.161.85";
      };

      "git.losfuzzys.net" = {
        User = "git";
        HostName = "git.losfuzzys.net";
        Port = 22222;
      };

      "losserver" = {
        User = "admin";
        HostName = "188.68.41.88";
      };

      "acsc-pve" = {
        User = "root";
        HostName = "167.235.95.92";
      };
    };
  };
}