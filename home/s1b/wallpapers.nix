# Fondos rotativos con awww (sucesor de swww).
# Imágenes en ~/Pictures/wallpapers/background/ (recursivo, fuera del store).
# Fallback: wallpaper de stylix (Neon S1B Hk generado) — también usa hyprlock.
{
  config,
  pkgs,
  ...
}:
let
  wallDir = "${config.home.homeDirectory}/Pictures/wallpapers/background";
  fallback = config.stylix.image;
  next = pkgs.writeShellApplication {
    name = "mango-wallpaper-next";
    runtimeInputs = [
      pkgs.awww
      pkgs.findutils
      pkgs.coreutils
      pkgs.gnused
    ];
    text = ''
      set -euo pipefail
      dir="${wallDir}"
      if [[ ! -d "$dir" ]]; then
        awww img "${fallback}" --transition-type fade --transition-duration 1
        exit 0
      fi
      mapfile -t files < <(find "$dir" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | shuf)
      if (( ''${#files[@]} == 0 )); then
        awww img "${fallback}" --transition-type fade --transition-duration 1
        exit 0
      fi
      # Aleatorio; evita repetir el fondo actual si hay más de uno.
      current=$(awww query 2>/dev/null | sed -n 's/.*image: //p' | head -n1 || true)
      pick="''${files[0]}"
      if [[ "$pick" == "$current" ]] && (( ''${#files[@]} > 1 )); then
        pick="''${files[1]}"
      fi
      awww img "$pick" --transition-type any --transition-fps 40 --transition-duration 1.4
    '';
  };
in
{
  home.packages = [
    pkgs.awww
    next
  ];

  systemd.user.services.awww = {
    Unit = {
      Description = "awww wallpaper daemon";
      PartOf = [ "mango-session.target" ];
      After = [ "mango-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.awww}/bin/awww-daemon";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "mango-session.target" ];
  };

  systemd.user.services.awww-init = {
    Unit = {
      Description = "Set initial wallpaper via awww";
      After = [ "awww.service" ];
      Requires = [ "awww.service" ];
      PartOf = [ "mango-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.awww}/bin/awww img ${fallback} --transition-type fade --transition-duration 0.6";
    };
    Install.WantedBy = [ "mango-session.target" ];
  };

  systemd.user.services.mango-wallpaper-rotate = {
    Unit = {
      Description = "Rotate desktop wallpaper";
      PartOf = [ "mango-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${next}/bin/mango-wallpaper-next";
    };
  };

  systemd.user.timers.mango-wallpaper-rotate = {
    Unit = {
      Description = "Rotate wallpaper every 15 minutes";
      PartOf = [ "mango-session.target" ];
    };
    Timer = {
      OnBootSec = "15min";
      OnUnitActiveSec = "15min";
      Persistent = false;
      Unit = "mango-wallpaper-rotate.service";
    };
    Install.WantedBy = [ "mango-session.target" ];
  };
}
