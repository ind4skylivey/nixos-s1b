# Shell: bash + starship (paleta Neon S1B Hk) + fastfetch + eza. Ligero.
{ config, pkgs, ... }:
let
  c = config.lib.stylix.colors.withHashtag;
in
{
  programs.bash = {
    enable = true;
    shellAliases = {
      ls = "eza --icons=auto --group-directories-first";
      ll = "eza -l --icons=auto --group-directories-first --git";
      la = "eza -la --icons=auto --group-directories-first";
      l = "eza -lah --icons=auto --group-directories-first";
      lt = "eza -l --sort=modified --reverse --icons=auto";
      tree = "eza --tree --icons=auto";
      sec = "nix develop ${config.home.homeDirectory}/nixos-mango#sec";
      re = "nix develop ${config.home.homeDirectory}/nixos-mango#re";
    };
    # fastfetch solo en la primera shell interactiva de kitty (no por ssh).
    initExtra = ''
      if [[ $- == *i* && -z "$SSH_CONNECTION" && "$TERM" == "xterm-kitty" && -z "$FASTFETCH_SHOWN" ]]; then
        export FASTFETCH_SHOWN=1
        fastfetch
      fi
    '';
  };

  home.packages = [ pkgs.eza ];

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      add_newline = true;
      palette = "neon_s1b_hk";
      palettes.neon_s1b_hk = {
        bg = c.base00;
        surface = c.base02;
        muted = c.base04;
        fg = c.base05;
        bright = c.base07;
        accent = c.base0D;
        magenta = c.base0E;
        red = c.base08;
        cyan = c.base0C;
        green = c.base0B;
        amber = c.base0A;
      };

      format = "[](accent)$os$username[](bg:surface fg:accent)$directory[](fg:surface)$git_branch$git_status$nix_shell$fill$cmd_duration$time$line_break$character";

      os = {
        disabled = false;
        style = "bg:accent fg:bg";
        format = "[$symbol]($style)";
        symbols.NixOS = " ";
      };
      username = {
        show_always = true;
        style_user = "bg:accent fg:bg bold";
        style_root = "bg:red fg:bg bold";
        format = "[$user ]($style)";
      };
      directory = {
        style = "bg:surface fg:bright";
        read_only = " 󰌾";
        read_only_style = "bg:surface fg:red";
        format = "[ $path$read_only ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        home_symbol = "~";
      };
      git_branch = {
        symbol = "";
        style = "fg:magenta";
        format = " [$symbol $branch]($style)";
      };
      git_status = {
        style = "fg:red";
        format = "[ $all_status$ahead_behind]($style)";
      };
      nix_shell = {
        symbol = "󱄅";
        style = "fg:cyan";
        format = " [$symbol $name]($style)";
      };
      fill.symbol = " ";
      cmd_duration = {
        min_time = 2000;
        style = "fg:amber";
        format = "[󱎫 $duration]($style) ";
      };
      time = {
        disabled = false;
        time_format = "%H:%M";
        style = "fg:muted";
        format = "[󰥔 $time]($style)";
      };
      character = {
        success_symbol = "[❯](bold accent)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold magenta)";
      };
    };
  };

  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "nixos_small";
        padding = {
          top = 1;
          right = 3;
          left = 1;
        };
        color = {
          "1" = c.base0D;
          "2" = c.base0E;
          "3" = c.base0D;
          "4" = c.base0E;
          "5" = c.base0D;
          "6" = c.base0E;
        };
      };
      display = {
        separator = "  ";
        color = {
          keys = c.base0D;
          title = c.base0E;
        };
        key.width = 10;
      };
      modules = [
        {
          type = "title";
          format = "{user-name}@{host-name}";
        }
        {
          type = "custom";
          format = "────────────────────────────";
        }
        {
          type = "os";
          key = " os";
        }
        {
          type = "kernel";
          key = " kernel";
        }
        {
          type = "wm";
          key = " wm";
        }
        {
          type = "terminal";
          key = " term";
        }
        {
          type = "shell";
          key = " shell";
        }
        {
          type = "packages";
          key = "󰏖 pkgs";
        }
        {
          type = "memory";
          key = "󰍛 ram";
        }
        {
          type = "uptime";
          key = "󰔟 uptime";
        }
        "break"
        {
          type = "colors";
          symbol = "circle";
          paddingLeft = 2;
        }
      ];
    };
  };
}
