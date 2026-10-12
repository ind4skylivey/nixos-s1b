# Tema global stylix + especializaciones de paleta (sin sudo extra:
# `sudo -n nixos-rebuild switch --specialisation <nombre>`).
{ pkgs, lib, ... }:
let
  schemes = import ./schemes.nix;
  walls = import ./wallpaper.nix pkgs;

  mkSpec = scheme: {
    configuration = {
      stylix.base16Scheme = lib.mkForce scheme;
    };
  };
in
{
  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = schemes.neon-s1b-hk;
    image = walls.wallpaper;

    fonts = {
      monospace = {
        package = pkgs.maple-mono.NF;
        name = "Maple Mono NF";
      };
      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        terminal = 14;
        applications = 12;
        desktop = 11;
        popups = 12;
      };
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme.override { color = "violet"; };
      dark = "Papirus-Dark";
      light = "Papirus-Light";
    };

    opacity = {
      terminal = 0.84;
      popups = 0.92;
    };
  };

  # JetBrainsMono queda como fallback del sistema; Symbols Nerd Font da los
  # iconos de nerd-icons (Emacs) a cualquier fuente.
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    symbola # respaldo unicode que busca Doom (unfree, uso personal)
    maple-mono.NF
    inter
  ];

  specialisation = {
    rose-pine = mkSpec schemes.rose-pine;
    tokyo-night = mkSpec schemes.tokyo-night;
    catppuccin-mocha = mkSpec schemes.catppuccin-mocha;
  };
}
