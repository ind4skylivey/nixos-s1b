# Menú de sesión wlogout (Super+Shift+E / botón ⏻ de waybar).
{ config, pkgs, ... }:
let
  c = config.lib.stylix.colors.withHashtag;
  icons = "${pkgs.wlogout}/share/wlogout/icons";
  layout = pkgs.writeText "wlogout-layout" ''
    {
        "label" : "lock",
        "action" : "hyprlock",
        "text" : "Lock",
        "keybind" : "l",
        "icon" : "${icons}/lock.png"
    }
    {
        "label" : "logout",
        "action" : "mmsg dispatch quit",
        "text" : "Log out",
        "keybind" : "e",
        "icon" : "${icons}/logout.png"
    }
    {
        "label" : "reboot",
        "action" : "systemctl reboot",
        "text" : "Reboot",
        "keybind" : "r",
        "icon" : "${icons}/reboot.png"
    }
    {
        "label" : "shutdown",
        "action" : "systemctl poweroff",
        "text" : "Shut down",
        "keybind" : "s",
        "icon" : "${icons}/shutdown.png"
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
    #lock { }
    #logout { }
    #reboot { }
    #shutdown {
        border-color: alpha(${c.base08}, 0.55);
    }
    #shutdown:focus, #shutdown:hover {
        background-color: alpha(${c.base08}, 0.35);
        border-color: ${c.base08};
        box-shadow: 0 0 18px alpha(${c.base08}, 0.45);
    }
  '';
in
{
  home.packages = [ pkgs.wlogout ];
  xdg.configFile."wlogout/layout".source = layout;
  xdg.configFile."wlogout/style.css".source = style;
}
