# Multimedia y apps por defecto: mpv (video/audio), zathura (PDF) y Neovim
# para texto/código. mpv y zathura toman los colores de stylix.
{ lib, ... }:
let
  videoTypes = [
    "video/mp4"
    "video/x-matroska"
    "video/webm"
    "video/quicktime"
    "video/x-msvideo"
    "video/mpeg"
    "video/ogg"
    "video/x-flv"
    "video/3gpp"
  ];
  audioTypes = [
    "audio/mpeg"
    "audio/flac"
    "audio/ogg"
    "audio/opus"
    "audio/wav"
    "audio/x-wav"
    "audio/aac"
    "audio/mp4"
    "audio/x-m4a"
    "audio/webm"
  ];
  textTypes = [
    "text/plain"
    "text/markdown"
    "text/x-markdown"
    "text/x-csrc"
    "text/x-chdr"
    "text/x-c++src"
    "text/x-python"
    "text/x-script.python"
    "text/x-shellscript"
    "application/x-shellscript"
    "text/x-lua"
    "text/rust"
    "text/x-rust"
    "text/x-php"
    "application/x-php"
    "text/x-nix"
    "text/css"
    "text/csv"
    "text/x-log"
    "application/json"
    "application/toml"
    "application/x-yaml"
    "application/yaml"
    "application/xml"
    "text/xml"
  ];
in
{
  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto-safe";
      keep-open = "yes";
      save-position-on-quit = "yes";
      osd-bar = "yes";
    };
  };

  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
      adjust-open = "width";
      recolor = false;
      guioptions = "";
    };
  };

  # Neovim dentro de kitty, para abrir texto desde Strata/Helium.
  xdg.desktopEntries.nvim-kitty = {
    name = "Neovim (kitty)";
    genericName = "Text Editor";
    exec = "kitty --class kitty-nvim -e nvim %F";
    icon = "nvim";
    terminal = false;
    categories = [
      "Utility"
      "TextEditor"
    ];
    mimeType = textTypes;
  };

  xdg.mimeApps.defaultApplications = {
    "application/pdf" = [ "org.pwmt.zathura.desktop" ];
  }
  // lib.genAttrs videoTypes (_: [ "mpv.desktop" ])
  // lib.genAttrs audioTypes (_: [ "mpv.desktop" ])
  // lib.genAttrs textTypes (_: [ "nvim-kitty.desktop" ]);
}
