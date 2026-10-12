# Apps de terminal tematizadas: btop, yazi (neovim vive en nvim.nix).
{ config, ... }:
let
  c = config.lib.stylix.colors;
in
{
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "neon-s1b-hk";
      theme_background = false;
      truecolor = true;
      rounded_corners = true;
      update_ms = 1000;
      proc_sorting = "cpu lazy";
    };
  };

  # Colores btop vía archivo de tema propio (TTY no usa stylix).
  xdg.configFile."btop/themes/neon-s1b-hk.theme".text = ''
    theme[main_bg]="#${c.base00}"
    theme[main_fg]="#${c.base05}"
    theme[title]="#${c.base0D}"
    theme[hi_fg]="#${c.base0E}"
    theme[selected_bg]="#${c.base02}"
    theme[selected_fg]="#${c.base07}"
    theme[inactive_fg]="#${c.base03}"
    theme[proc_misc]="#${c.base0C}"
    theme[cpu_box]="#${c.base0D}"
    theme[mem_box]="#${c.base0E}"
    theme[net_box]="#${c.base0C}"
    theme[proc_box]="#${c.base08}"
    theme[div_line]="#${c.base02}"
    theme[temp_start]="#${c.base0B}"
    theme[temp_mid]="#${c.base0A}"
    theme[temp_end]="#${c.base08}"
    theme[cpu_start]="#${c.base0D}"
    theme[cpu_mid]="#${c.base0E}"
    theme[cpu_end]="#${c.base08}"
    theme[free_start]="#${c.base0B}"
    theme[free_mid]="#${c.base0C}"
    theme[free_end]="#${c.base0D}"
    theme[cached_start]="#${c.base0A}"
    theme[cached_mid]="#${c.base09}"
    theme[cached_end]="#${c.base08}"
    theme[available_start]="#${c.base0B}"
    theme[available_mid]="#${c.base0C}"
    theme[available_end]="#${c.base0D}"
    theme[used_start]="#${c.base0E}"
    theme[used_mid]="#${c.base08}"
    theme[used_end]="#${c.base0F}"
    theme[download_start]="#${c.base0C}"
    theme[download_mid]="#${c.base0D}"
    theme[download_end]="#${c.base0E}"
    theme[upload_start]="#${c.base0A}"
    theme[upload_mid]="#${c.base09}"
    theme[upload_end]="#${c.base08}"
  '';

  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      manager = {
        show_hidden = false;
        sort_by = "alphabetical";
        sort_dir_first = true;
        ratio = [
          1
          3
          3
        ];
      };
    };
  };

  stylix.targets.btop.enable = false;
  stylix.targets.yazi.enable = true;
}
