# Menú de sesión wlogout (Super+Shift+E / botón ⏻ de waybar).
{ config, pkgs, ... }:
let
  c = config.lib.stylix.colors.withHashtag;
  icons = "${pkgs.wlogout}/share/wlogout/icons";
  # Cierra mango por IPC; si el socket no responde, termina la sesión logind.
  logout = pkgs.writeShellApplication {
    name = "session-logout";
    runtimeInputs = [ pkgs.systemd ];
    text = ''
      if command -v mmsg >/dev/null && mmsg dispatch quit; then exit 0; fi
      exec loginctl terminate-session "''${XDG_SESSION_ID:-self}"
    '';
  };
  layout = pkgs.writeText "wlogout-layout" ''
    {
        "label" : "lock",
        "action" : "hyprlock",
        "text" : "Lock",
        "keybind" : "l"
    }
    {
        "label" : "logout",
        "action" : "${logout}/bin/session-logout",
        "text" : "Log out",
        "keybind" : "e"
    }
    {
        "label" : "reboot",
        "action" : "systemctl reboot",
        "text" : "Reboot",
        "keybind" : "r"
    }
    {
        "label" : "shutdown",
        "action" : "systemctl poweroff",
        "text" : "Shut down",
        "keybind" : "s"
    }
  '';
  style = pkgs.writeText "wlogout-style.css" ''
    * {
        background-image: none;
        font-family: "${config.stylix.fonts.sansSerif.name}", "${config.stylix.fonts.monospace.name}";
        font-size: 15px;
        font-weight: 600;
    }
    window {
        background-color: alpha(${c.base00}, 0.78);
    }
    button {
        color: ${c.base05};
        background-color: alpha(${c.base01}, 0.92);
        border: 1px solid alpha(${c.base0D}, 0.35);
        border-radius: 22px;
        background-repeat: no-repeat;
        background-position: center 28%;
        background-size: 28%;
        margin: 10px;
        padding: 18px;
        box-shadow: 0 4px 18px alpha(#000000, 0.35);
        transition: all 180ms ease;
    }
    button:focus, button:hover {
        background-color: alpha(${c.base0D}, 0.28);
        border-color: ${c.base0D};
        color: ${c.base07};
        box-shadow: 0 0 18px alpha(${c.base0D}, 0.45);
    }
    /* wlogout no acepta "icon" en el layout: los iconos van por CSS. */
    #lock { background-image: url("${icons}/lock.png"); }
    #logout { background-image: url("${icons}/logout.png"); }
    #reboot { background-image: url("${icons}/reboot.png"); }
    #shutdown {
        background-image: url("${icons}/shutdown.png");
        border-color: alpha(${c.base08}, 0.55);
    }
    #shutdown:focus, #shutdown:hover {
        background-color: alpha(${c.base08}, 0.35);
        border-color: ${c.base08};
        box-shadow: 0 0 18px alpha(${c.base08}, 0.45);
    }
  '';

  # Abre/cierra el menú (un segundo Super+Shift+E lo cierra). Sin suspender:
  # en la VM no aplica.
  powerMenu = pkgs.writeShellApplication {
    name = "power-menu";
    runtimeInputs = with pkgs; [
      wlogout
      procps
    ];
    text = ''
      if pkill -x wlogout; then exit 0; fi
      exec wlogout -p layer-shell -b 4 -T 280 -B 280 -L 400 -R 400 "$@"
    '';
  };
in
{
  home.packages = [
    pkgs.wlogout
    powerMenu
  ];
  xdg.configFile."wlogout/layout".source = layout;
  xdg.configFile."wlogout/style.css".source = style;
}
