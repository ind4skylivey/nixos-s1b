# Selector de paleta vía rofi → especialización NixOS.
# Requiere: sudo -n solo para /run/current-system/sw/bin/nixos-rebuild.
{
  config,
  pkgs,
  ...
}:
let
  flake = "${config.home.homeDirectory}/nixos-mango";
  switcher = pkgs.writeShellApplication {
    name = "mango-theme-switch";
    runtimeInputs = [
      config.programs.rofi.finalPackage
      pkgs.coreutils
      pkgs.libnotify
    ];
    text = ''
      set -euo pipefail
      rebuild="/run/current-system/sw/bin/nixos-rebuild"
      choice=$(printf '%s\n' \
        "  Neon S1B Hk (default)" \
        "󰱮  Rosé Pine" \
        "  Tokyo Night" \
        "  Catppuccin Mocha" |
        rofi -dmenu -i -p "󰏘  Theme" -no-custom) || exit 0
      case "$choice" in
        *"Neon S1B Hk"*)
          notify-send -a theme "Applying Neon S1B Hk…" "Base specialisation"
          sudo -n "$rebuild" switch --flake "path:${flake}#nixos"
          ;;
        *"Rosé Pine"*)
          notify-send -a theme "Applying Rosé Pine…" "Specialisation"
          sudo -n "$rebuild" switch --flake "path:${flake}#nixos" --specialisation rose-pine
          ;;
        *"Tokyo Night"*)
          notify-send -a theme "Applying Tokyo Night…" "Specialisation"
          sudo -n "$rebuild" switch --flake "path:${flake}#nixos" --specialisation tokyo-night
          ;;
        *"Catppuccin"*)
          notify-send -a theme "Applying Catppuccin Mocha…" "Specialisation"
          sudo -n "$rebuild" switch --flake "path:${flake}#nixos" --specialisation catppuccin-mocha
          ;;
        *) exit 0 ;;
      esac
      notify-send -a theme "Done" "$choice applied. You may need to reload waybar (Super+Shift+W)."
    '';
  };
in
{
  home.packages = [ switcher ];
}
