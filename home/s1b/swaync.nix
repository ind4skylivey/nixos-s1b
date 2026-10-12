# swaync "Neon S1B Hk": notificaciones y centro de control (Super+N / campana).
# Tarjetas redondeadas sobre violeta oscuro, acento morado, críticas en rojo.
{ config, ... }:
let
  c = config.lib.stylix.colors.withHashtag;
  fonts = config.stylix.fonts;
in
{
  services.swaync = {
    enable = true;

    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "top";
      control-center-margin-top = 8;
      control-center-margin-bottom = 8;
      control-center-margin-right = 10;
      control-center-margin-left = 0;
      notification-margin-top = 4;
      notification-margin-right = 10;
      notification-icon-size = 48;
      notification-body-image-height = 160;
      notification-body-image-width = 200;
      timeout = 5;
      timeout-low = 3;
      timeout-critical = 0;
      fit-to-screen = true;
      control-center-width = 420;
      notification-window-width = 400;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 220;
      hide-on-clear = false;
      hide-on-action = true;
      widgets = [
        "title"
        "buttons-grid"
        "volume"
        "mpris"
        "dnd"
        "notifications"
      ];
      widget-config = {
        title = {
          text = "Notifications";
          clear-all-button = true;
          button-text = "󰎟  Clear";
        };
        dnd.text = "Do not disturb";
        # Sin esta entrada swaync avisa "notifications: Config not found".
        notifications.vexpand = true;
        mpris = {
          image-size = 64;
          autohide = true;
        };
        volume = {
          label = "󰕾";
          show-per-app = false;
        };
        buttons-grid.buttons-per-row = 5;
        buttons-grid.actions = [
          {
            label = "󰌾";
            command = "sh -c 'swaync-client -cp; hyprlock'";
            tooltip = "Lock";
          }
          {
            label = "󰹑";
            command = "sh -c 'swaync-client -cp; sleep 0.4; grim - | wl-copy'";
            tooltip = "Screenshot to clipboard";
          }
          {
            label = "󰕾";
            command = "sh -c 'swaync-client -cp; pavucontrol'";
            tooltip = "Mixer";
          }
          {
            label = "";
            command = "sh -c 'swaync-client -cp; kitty'";
            tooltip = "Terminal";
          }
          {
            label = "⏻";
            command = "sh -c 'swaync-client -cp; wlogout -p layer-shell -b 4 -T 280 -B 280 -L 400 -R 400'";
            tooltip = "Session";
          }
        ];
      };
    };

    style = ''
      @define-color bg ${c.base00};
      @define-color surface ${c.base01};
      @define-color overlay ${c.base02};
      @define-color muted ${c.base03};
      @define-color subtle ${c.base04};
      @define-color fg ${c.base05};
      @define-color bright ${c.base07};
      @define-color accent ${c.base0D};
      @define-color magenta ${c.base0E};
      @define-color red ${c.base08};

      * {
          font-family: "${fonts.sansSerif.name}", "${fonts.monospace.name}";
          font-size: 14px;
          outline: none;
          box-shadow: none;
          text-shadow: none;
      }

      /* ---------------- notificaciones flotantes ---------------- */
      row,
      row:focus,
      row:hover,
      row:selected,
      .notification-row,
      .notification-row:focus,
      .notification-row:hover,
      .notification-background,
      .notification-group,
      .notification-group:focus {
          background: transparent;
          outline: none;
          box-shadow: none;
      }

      .notification-background { padding: 4px 2px; }

      .notification {
          background: alpha(@bg, 0.92);
          border: 1px solid alpha(@accent, 0.30);
          border-radius: 16px;
          padding: 0;
          box-shadow: 0 4px 14px alpha(#000000, 0.45);
      }
      .notification.critical {
          border-color: alpha(@red, 0.75);
          box-shadow: 0 0 12px alpha(@red, 0.30);
      }
      .notification.low { border-color: alpha(@muted, 0.6); }

      .notification-default-action,
      .notification-action {
          background: transparent;
          color: @fg;
          border: none;
          border-radius: 16px;
      }
      .notification-default-action { padding: 12px; }
      .notification-default-action:hover,
      .notification-action:hover { background: alpha(@accent, 0.10); }
      .notification-action {
          border-top: 1px solid alpha(@accent, 0.15);
          border-radius: 0 0 16px 16px;
          padding: 6px;
      }

      .summary { color: @bright; font-weight: 700; font-size: 14.5px; }
      .notification.critical .summary { color: @red; }
      .body { color: @subtle; }
      .time { color: @muted; font-size: 12px; margin-right: 22px; }
      .image { border-radius: 12px; }
      .notification .app-icon { color: @accent; }

      .close-button {
          background: alpha(@overlay, 0.9);
          color: @fg;
          border-radius: 99px;
          min-width: 22px;
          min-height: 22px;
          margin: 8px;
          padding: 0;
          border: none;
      }
      .close-button:hover { background: @red; color: @bg; }

      .notification-group-headers { color: @subtle; }
      .notification-group-icon { color: @accent; }
      .notification-group-collapse-button,
      .notification-group-close-all-button {
          background: alpha(@overlay, 0.9);
          border-radius: 99px;
          border: none;
          color: @fg;
      }

      /* ---------------- centro de control ---------------- */
      .control-center {
          background: alpha(@bg, 0.96);
          border: 1px solid alpha(@accent, 0.30);
          border-radius: 20px;
          padding: 14px;
          color: @fg;
          box-shadow: 0 6px 20px alpha(#000000, 0.5);
      }
      .control-center-list { background: transparent; }
      .control-center-list-placeholder { color: @muted; }

      .widget-title {
          color: @bright;
          font-size: 17px;
          font-weight: 700;
          margin: 4px 6px 10px;
      }
      .widget-title > button {
          background: alpha(@overlay, 0.9);
          color: @fg;
          border: 1px solid alpha(@accent, 0.25);
          border-radius: 12px;
          padding: 4px 12px;
          font-size: 12px;
      }
      .widget-title > button:hover { background: alpha(@red, 0.85); color: @bg; border-color: @red; }

      .widget-buttons-grid {
          background: alpha(@surface, 0.9);
          border-radius: 16px;
          padding: 8px;
          margin: 0 0 10px;
      }
      .widget-buttons-grid > flowbox > flowboxchild > button {
          background: alpha(@overlay, 0.85);
          color: @fg;
          border: none;
          border-radius: 12px;
          min-height: 40px;
          min-width: 40px;
          margin: 2px;
          font-family: "${fonts.monospace.name}";
          font-size: 16px;
      }
      .widget-buttons-grid > flowbox > flowboxchild > button:hover {
          background: alpha(@accent, 0.30);
          color: @bright;
      }

      .widget-volume {
          background: alpha(@surface, 0.9);
          border-radius: 16px;
          padding: 8px 14px;
          margin: 0 0 10px;
          color: @accent;
          font-family: "${fonts.monospace.name}";
      }
      trough { background: alpha(@overlay, 0.9); border-radius: 99px; min-height: 6px; }
      trough highlight { background: linear-gradient(90deg, @accent, @magenta); border-radius: 99px; }
      trough slider { background: @bright; border-radius: 99px; min-width: 12px; min-height: 12px; margin: -4px 0; }

      .widget-mpris {
          background: alpha(@surface, 0.9);
          border-radius: 16px;
          padding: 8px;
          margin: 0 0 10px;
      }
      .widget-mpris-player { background: transparent; }
      .widget-mpris-title { color: @bright; font-weight: 700; }
      .widget-mpris-subtitle { color: @subtle; }

      .widget-dnd {
          background: alpha(@surface, 0.9);
          border-radius: 16px;
          padding: 8px 14px;
          margin: 0 0 10px;
          color: @fg;
      }
      .widget-dnd > switch {
          background: alpha(@overlay, 0.95);
          border-radius: 99px;
          border: none;
      }
      .widget-dnd > switch:checked { background: @accent; }
      .widget-dnd > switch slider { background: @bright; border-radius: 99px; }
    '';
  };
}
