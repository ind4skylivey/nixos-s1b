# Capturas: grim + slurp + satty (anotar). Ver binds en mango.nix.
{ config, pkgs, ... }:
let
  c = config.lib.stylix.colors.withHashtag;
  shotDir = "${config.home.homeDirectory}/Pictures/Screenshots";
  shot = pkgs.writeShellApplication {
    name = "mango-screenshot";
    runtimeInputs = with pkgs; [
      grim
      slurp
      satty
      wl-clipboard
      libnotify
      coreutils
    ];
    text = ''
      mkdir -p "${shotDir}"
      case "''${1:-region}" in
        region)
          # Región → satty (anotar; Ctrl+C copia, Ctrl+S guarda).
          geom=$(slurp) || exit 0
          grim -g "$geom" - | satty --filename -
          ;;
        full)
          f="${shotDir}/screenshot-$(date +%Y%m%d-%H%M%S).png"
          grim "$f"
          wl-copy --type image/png < "$f"
          notify-send -a screenshot "Screenshot saved" "$f (copied to clipboard)"
          ;;
        *)
          echo "usage: mango-screenshot [region|full]" >&2
          exit 2
          ;;
      esac
    '';
  };
in
{
  home.packages = [
    shot
    pkgs.satty
  ];

  xdg.configFile."satty/config.toml".text = ''
    [general]
    early-exit = true
    initial-tool = "arrow"
    copy-command = "wl-copy"
    output-filename = "${shotDir}/satty-%Y%m%d-%H%M%S.png"
    save-after-copy = false
    default-hide-toolbars = false

    [font]
    family = "${config.stylix.fonts.sansSerif.name}"

    [color-palette]
    palette = ["${c.base0D}", "${c.base0E}", "${c.base08}", "${c.base0B}", "${c.base0A}", "${c.base07}"]
  '';
}
