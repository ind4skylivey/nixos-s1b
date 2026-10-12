# Terminal: kitty. Colores, fuente y opacidad base los pone stylix; aquí se
# afina el aspecto (padding, cursor con estela, pestañas, acento morado).
{ config, lib, ... }:
let
  c = config.lib.stylix.colors.withHashtag;
in
{
  programs.kitty = {
    enable = true;
    settings = {
      # Maple Mono NF (stylix); JetBrains como respaldo explícito.
      font_family = "Maple Mono NF";
      bold_font = "Maple Mono NF Bold";
      italic_font = "Maple Mono NF Italic";
      bold_italic_font = "Maple Mono NF Bold Italic";
      font_features = "MapleMono-NF +calt +liga +ss01";

      confirm_os_window_close = 0;
      enable_audio_bell = false;
      visual_bell_duration = 0;
      scrollback_lines = 10000;

      # Aire alrededor del texto y líneas un poco más altas (más legible).
      window_padding_width = "12 16";
      modify_font = "cell_height 108%";
      disable_ligatures = "never";

      # Cursor fino con estela suave (kitty >= 0.37).
      cursor_shape = "beam";
      cursor_beam_thickness = "1.6";
      cursor_blink_interval = "0.7";
      cursor_stop_blinking_after = 10;
      cursor_trail = 3;
      cursor_trail_decay = "0.08 0.35";
      cursor_trail_start_threshold = 2;

      # Pestañas redondeadas abajo.
      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";
      tab_powerline_style = "round";
      tab_title_template = "{index}: {title}";

      url_style = "curly";
      mouse_hide_wait = 2;
      sync_to_monitor = true;
    };

    # Después del tema de stylix: acentos propios.
    extraConfig = lib.mkAfter ''
      cursor ${c.base0D}
      cursor_text_color ${c.base00}
      url_color ${c.base0C}
      selection_background ${c.base03}
      selection_foreground ${c.base07}
      active_tab_background ${c.base0D}
      active_tab_foreground ${c.base00}
      inactive_tab_background ${c.base01}
      inactive_tab_foreground ${c.base04}
      tab_bar_background ${c.base00}
    '';
  };
}
