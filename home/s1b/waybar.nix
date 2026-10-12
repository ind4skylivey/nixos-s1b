# Waybar "Neon S1B Hk": islas flotantes redondeadas, brillo sutil, morado
# activo / rojo urgente. Colores de stylix (esquema base16 en modules/stylix.nix).
#
#  izquierda : lanzador · tags de mango (ext/workspaces) · título de ventana
#  centro    : reloj + fecha (calendario en el tooltip)
#  derecha   : CPU/RAM/red · volumen · bandeja · notificaciones · apagado
{
  config,
  pkgs,
  ...
}:
let
  c = config.lib.stylix.colors.withHashtag;
  mango = config.wayland.windowManager.mango.package;

  # Título de la ventana enfocada vía IPC de mango (no hay módulo mango/* en
  # waybar 0.15). Emite JSON por línea para custom/window.
  windowTitle = pkgs.writeShellApplication {
    name = "waybar-mango-window";
    runtimeInputs = [
      mango
      pkgs.jq
    ];
    text = ''
      mmsg watch focusing-client | jq --unbuffered -c '
        (.title // "") as $t | (.appid // "") as $a |
        ({ "kitty": "", "firefox": "󰈹", "org.pulseaudio.pavucontrol": "󰕾",
           "thunar": "", "io.github.lgse.Strata": "", "helium": "󰖟", "code": "󰨞", "chromium-browser": "" }[$a] // "") as $i |
        if $t == "" then { text: "", class: "empty" }
        else {
          text: ($i + "  " + (if ($t | length) > 34 then $t[0:33] + "…" else $t end)),
          tooltip: ($a + "\n" + $t),
          class: "focused"
        } end'
    '';
  };
in
{
  home.packages = [ windowTitle ];

  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      targets = [ "mango-session.target" ];
    };

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 38;
      margin-top = 8;
      margin-left = 10;
      margin-right = 10;
      spacing = 0;
      reload_style_on_change = true;

      modules-left = [
        "custom/launcher"
        "ext/workspaces"
        "custom/window"
      ];
      modules-center = [ "clock" ];
      modules-right = [
        "cava"
        "group/sys"
        "pulseaudio"
        "tray"
        "custom/notification"
        "custom/power"
      ];

      "custom/launcher" = {
        format = "";
        tooltip-format = "Applications (Super+D)";
        on-click = "rofi -show drun";
        on-click-right = "rofi -show window";
      };

      # mango publica sus 9 tags por ext-workspace-v1: vacíos = "hidden".
      "ext/workspaces" = {
        format = "{name}";
        on-click = "activate";
        ignore-hidden = false;
        sort-by-name = true;
      };

      "custom/window" = {
        exec = "${windowTitle}/bin/waybar-mango-window";
        return-type = "json";
        restart-interval = 3;
        escape = true;
        hide-empty-text = true;
      };

      clock = {
        format = "󰥔  {:L%H:%M  ·  %a %d %b}";
        format-alt = "󰃭  {:L%A, %d %B %Y}";
        locale = "en_US.UTF-8";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
        calendar = {
          mode = "month";
          weeks-pos = "";
          on-scroll = 1;
          format = {
            months = "<span color='${c.base0D}'><b>{}</b></span>";
            days = "<span color='${c.base05}'>{}</span>";
            weekdays = "<span color='${c.base0E}'><b>{}</b></span>";
            today = "<span color='${c.base08}'><b><u>{}</u></b></span>";
          };
        };
        actions = {
          on-click-right = "mode";
          on-scroll-up = "shift_up";
          on-scroll-down = "shift_down";
        };
      };

      "group/sys" = {
        orientation = "horizontal";
        modules = [
          "cpu"
          "memory"
          "network"
        ];
      };
      cpu = {
        interval = 3;
        format = "󰻠 {usage}%";
        tooltip-format = "CPU {usage}% · load {load}";
        states.critical = 85;
      };
      memory = {
        interval = 5;
        format = "󰍛 {percentage}%";
        tooltip-format = "RAM {used:0.1f} / {total:0.1f} GiB";
        states.critical = 85;
      };
      network = {
        interval = 5;
        format-ethernet = "󰈀";
        format-wifi = "󰤨";
        format-disconnected = "󰤭";
        format-linked = "󰈂";
        tooltip-format = "{ifname} · {ipaddr}/{cidr}\n↓ {bandwidthDownBytes}   ↑ {bandwidthUpBytes}";
        tooltip-format-disconnected = "Disconnected";
        on-click-right = "kitty -e nmtui";
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰝟 mute";
        format-icons = {
          headphone = "󰋋";
          default = [
            "󰕿"
            "󰖀"
            "󰕾"
          ];
        };
        scroll-step = 5;
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-click-right = "pavucontrol";
        tooltip-format = "{desc} · {volume}%";
      };

      tray = {
        icon-size = 16;
        spacing = 8;
      };

      cava = {
        framerate = 30;
        autosens = 1;
        bars = 12;
        lower_cutoff_freq = 50;
        higher_cutoff_freq = 10000;
        method = "pipewire";
        source = "auto";
        stereo = true;
        reverse = false;
        bar_delimiter = 0;
        monstercat = false;
        waves = false;
        noise_reduction = 0.77;
        input_delay = 2;
        format-icons = [ "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" ];
        actions.on-click-right = "mode";
        hide_on_silence = true;
        sleep_timer = 3;
      };

      "custom/notification" = {
        tooltip = false;
        format = "{icon}";
        format-icons = {
          notification = "󰂚<span foreground='${c.base08}'><sup>●</sup></span>";
          none = "󰂜";
          dnd-notification = "󰂛<span foreground='${c.base08}'><sup>●</sup></span>";
          dnd-none = "󰂛";
          inhibited-notification = "󰂚<span foreground='${c.base08}'><sup>●</sup></span>";
          inhibited-none = "󰂜";
          dnd-inhibited-notification = "󰂛<span foreground='${c.base08}'><sup>●</sup></span>";
          dnd-inhibited-none = "󰂛";
        };
        return-type = "json";
        exec-if = "which swaync-client";
        exec = "swaync-client -swb";
        on-click = "swaync-client -t -sw";
        on-click-right = "swaync-client -d -sw";
        escape = true;
      };

      "custom/power" = {
        format = "⏻";
        tooltip-format = "Session (Super+Shift+Q)";
        on-click = "wlogout -p layer-shell -b 4 -T 280 -B 280 -L 400 -R 400";
      };
    };

    style = ''
      @define-color bg ${c.base00};
      @define-color surface ${c.base01};
      @define-color overlay ${c.base02};
      @define-color muted ${c.base03};
      @define-color subtle ${c.base04};
      @define-color fg ${c.base05};
      @define-color accent ${c.base0D};
      @define-color magenta ${c.base0E};
      @define-color red ${c.base08};
      @define-color cyan ${c.base0C};
      @define-color green ${c.base0B};
      @define-color amber ${c.base0A};

      * {
          font-family: "JetBrainsMono Nerd Font Propo", "Inter", sans-serif;
          font-size: 14.5px;
          font-weight: 600;
          min-height: 0;
          border: none;
          border-radius: 0;
      }

      window#waybar {
          background: transparent;
          color: @fg;
      }

      tooltip {
          background: alpha(@surface, 0.97);
          border: 1px solid alpha(@accent, 0.45);
          border-radius: 12px;
      }
      tooltip label {
          color: @fg;
          padding: 4px 6px;
      }

      /* ---- islas ---- */
      #custom-launcher,
      #workspaces,
      #custom-window,
      #clock,
      #cava,
      #sys,
      #pulseaudio,
      #tray,
      #custom-notification,
      #custom-power {
          background: alpha(@bg, 0.78);
          border: 1px solid alpha(@accent, 0.20);
          border-radius: 14px;
          margin: 3px 4px;
          padding: 0 12px;
          box-shadow: 0 2px 6px alpha(#000000, 0.35);
          transition: all 200ms ease;
      }

      #custom-launcher {
          color: @accent;
          font-size: 17px;
          padding: 0 13px 0 11px;
          text-shadow: 0 0 6px alpha(@accent, 0.6);
      }
      #custom-launcher:hover {
          color: @magenta;
          border-color: alpha(@magenta, 0.55);
      }

      /* ---- tags de mango ---- */
      #workspaces {
          padding: 0 4px;
      }
      #workspaces button {
          color: @fg;
          background: transparent;
          padding: 0 6px;
          margin: 4px 1px;
          border-radius: 10px;
          box-shadow: none;
          text-shadow: none;
          min-width: 12px;
          transition: all 250ms cubic-bezier(0.2, 0.8, 0.2, 1);
      }
      #workspaces button.hidden {
          color: @muted;
      }
      #workspaces button:hover {
          background: alpha(@accent, 0.18);
          color: @fg;
      }
      #workspaces button.active {
          background: linear-gradient(90deg, @accent, @magenta);
          color: @bg;
          min-width: 26px;
          box-shadow: 0 0 8px alpha(@accent, 0.55);
      }
      #workspaces button.urgent {
          background: @red;
          color: @bg;
          box-shadow: 0 0 8px alpha(@red, 0.6);
      }

      #custom-window {
          color: @subtle;
          font-weight: 500;
      }

      /* ---- centro ---- */
      #clock {
          color: @fg;
          padding: 0 16px;
          border-color: alpha(@accent, 0.35);
      }

      /* ---- derecha ---- */
      #cpu,
      #memory,
      #network {
          padding: 0 6px;
      }
      #cpu { color: @accent; }
      #memory { color: @magenta; }
      #network { color: @cyan; }
      #network.disconnected { color: @red; }
      #cpu.critical,
      #memory.critical { color: @red; }

      #cava {
          color: @accent;
          padding: 0 10px;
          min-width: 70px;
      }
      #pulseaudio { color: @fg; }
      #pulseaudio.muted { color: @muted; }

      #tray { padding: 0 10px; }
      #tray > .needs-attention { background: alpha(@red, 0.3); border-radius: 8px; }

      #custom-notification {
          color: @fg;
          padding: 0 13px 0 11px;
      }

      #custom-power {
          color: @red;
          padding: 0 14px 0 12px;
          text-shadow: 0 0 6px alpha(@red, 0.5);
      }

      #custom-power:hover,
      #custom-notification:hover,
      #clock:hover,
      #pulseaudio:hover {
          background: alpha(@overlay, 0.92);
          border-color: alpha(@red, 0.55);
      }
    '';
  };
}
