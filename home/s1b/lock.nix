# Bloqueo de pantalla: hyprlock (ext-session-lock, soportado por mango).
# Fondo desenfocado pre-generado en Nix (sin blur en GPU: amable con virgl).
# Atajo: Super+Escape (y "Bloquear" en el menú de sesión / swaync).
{ config, pkgs, ... }:
let
  c = config.lib.stylix.colors;
  walls = import ../../modules/wallpaper.nix pkgs;
  font = config.stylix.fonts.sansSerif.name;
  mono = config.stylix.fonts.monospace.name;
  rgba = hex: a: "rgba(${hex}${a})";
in
{
  stylix.targets.hyprlock.enable = false;

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
        grace = 0;
      };
      animations = {
        enabled = true;
        bezier = [ "ease, 0.2, 0.8, 0.2, 1" ];
        animation = [
          "fadeIn, 1, 4, ease"
          "fadeOut, 1, 4, ease"
          "inputFieldDots, 1, 2, ease"
        ];
      };

      background = [
        {
          monitor = "";
          path = "${walls.lock}";
          blur_passes = 0;
          color = rgba c.base00 "ff";
        }
      ];

      shape = [
        {
          monitor = "";
          size = "380, 460";
          color = rgba c.base00 "b3";
          rounding = 28;
          border_size = 1;
          border_color = rgba c.base0D "55";
          position = "0, 0";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        {
          monitor = "";
          text = ''cmd[update:1000] date +"%H:%M"'';
          color = rgba c.base07 "ff";
          font_size = 84;
          font_family = "${font} Bold";
          shadow_passes = 2;
          shadow_size = 6;
          shadow_color = rgba c.base0D "66";
          position = "0, 110";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = ''cmd[update:60000] LC_TIME=en_US.UTF-8 date +"%A, %d %B"'';
          color = rgba c.base04 "ff";
          font_size = 14;
          font_family = font;
          position = "0, 30";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "  $USER";
          color = rgba c.base0D "ff";
          font_size = 13;
          font_family = mono;
          position = "0, -40";
          halign = "center";
          valign = "center";
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "260, 46";
          outline_thickness = 2;
          rounding = 14;
          outer_color = "${rgba c.base0D "cc"} ${rgba c.base0E "cc"} 45deg";
          inner_color = rgba c.base01 "e6";
          font_color = rgba c.base05 "ff";
          font_family = mono;
          check_color = "${rgba c.base0A "cc"} ${rgba c.base09 "cc"} 45deg";
          fail_color = "${rgba c.base08 "ee"} ${rgba c.base0F "ee"} 45deg";
          fail_text = "<i>$FAIL ($ATTEMPTS)</i>";
          placeholder_text = "<span foreground='##${c.base04}'>Password…</span>";
          dots_size = 0.22;
          dots_spacing = 0.35;
          dots_center = true;
          fade_on_empty = false;
          position = "0, -110";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
