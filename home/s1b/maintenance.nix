# Mantenimiento del día a día (servicios de usuario):
#   - luz nocturna (wlsunset) con horario fijo y toggle Super+Ctrl+N
#   - aviso de disco casi lleno (cada 30 min)
#   - recordatorio mensual para actualizar flake.lock (no actualiza solo)
#   - backup con restic, apagado hasta que exista ~/.config/restic/env
{
  config,
  pkgs,
  ...
}:
let
  flake = "${config.home.homeDirectory}/nixos-mango";
  notify = "${pkgs.libnotify}/bin/notify-send";

  nightlightToggle = pkgs.writeShellApplication {
    name = "nightlight-toggle";
    runtimeInputs = [
      pkgs.systemd
      pkgs.libnotify
    ];
    text = ''
      if systemctl --user is-active --quiet wlsunset.service; then
        systemctl --user stop wlsunset.service
        notify-send -u low -a nightlight "Night light" "Off"
      else
        systemctl --user start wlsunset.service
        notify-send -u low -a nightlight "Night light" "On (warm after sunset)"
      fi
    '';
  };

  diskCheck = pkgs.writeShellApplication {
    name = "low-disk-check";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gawk
      pkgs.libnotify
    ];
    text = ''
      # Avisa si / o /home pasan del umbral (por defecto 90 %).
      limit="''${LOW_DISK_PERCENT:-90}"
      for mp in / /home; do
        used=$(df --output=pcent "$mp" | awk 'NR==2 { gsub("%", ""); print $1 }')
        if (( used >= limit )); then
          free=$(df -h --output=avail "$mp" | awk 'NR==2 { print $1 }')
          notify-send -u critical -a disk "Low disk space" \
            "$mp is ''${used}% full (''${free} free). Try: nh clean all --keep 5"
        fi
      done
    '';
  };

  updateReminder = pkgs.writeShellApplication {
    name = "flake-update-reminder";
    runtimeInputs = [
      pkgs.git
      pkgs.libnotify
    ];
    text = ''
      age=$(git -C "${flake}" log -1 --format=%cr -- flake.lock 2>/dev/null || echo "unknown")
      notify-send -a nixos "Monthly update" \
        "flake.lock last changed $age. When you have time: cd ~/nixos-mango && nix flake update, then rebuild and commit."
    '';
  };

  # Backup: el destino y la contraseña viven fuera del repo, en
  # ~/.config/restic/env (ver README → Backups). Sin ese archivo el servicio
  # ni arranca (ConditionPathExists).
  backup = pkgs.writeShellApplication {
    name = "restic-home-backup";
    runtimeInputs = [
      pkgs.restic
      pkgs.libnotify
      pkgs.coreutils
    ];
    text = ''
      : "''${RESTIC_REPOSITORY:?set RESTIC_REPOSITORY in ~/.config/restic/env}"
      # Repositorio local (ruta): si el disco no está montado, no se hace nada.
      if [[ "$RESTIC_REPOSITORY" == /* && ! -d "$RESTIC_REPOSITORY" ]]; then
        echo "Backup target $RESTIC_REPOSITORY not present; skipping."
        exit 0
      fi
      restic backup --one-file-system --exclude-caches \
        --exclude "$HOME/.cache" \
        --exclude "$HOME/.local/share/Trash" \
        --exclude "$HOME/.config/emacs/.local" \
        --exclude "$HOME/.local/state" \
        --exclude "$HOME/Downloads" \
        "$HOME" "$HOME/nixos-mango/local"
      restic forget --prune --keep-daily 7 --keep-weekly 4 --keep-monthly 6
      notify-send -u low -a restic "Backup" "Home backup finished"
    '';
  };
in
{
  home.packages = [
    nightlightToggle
    diskCheck
    updateReminder
    backup
    pkgs.restic
  ];

  # Horario fijo (sin ubicación): cálido de 20:00 a 07:00.
  services.wlsunset = {
    enable = true;
    systemdTarget = "mango-session.target";
    sunrise = "07:00";
    sunset = "20:00";
    temperature = {
      day = 6500;
      night = 4000;
    };
  };

  systemd.user.services.low-disk-check = {
    Unit.Description = "Warn when / or /home is almost full";
    Service = {
      Type = "oneshot";
      ExecStart = "${diskCheck}/bin/low-disk-check";
    };
  };
  systemd.user.timers.low-disk-check = {
    Unit.Description = "Check free disk space every 30 minutes";
    Timer = {
      OnBootSec = "5min";
      OnUnitActiveSec = "30min";
    };
    Install.WantedBy = [ "timers.target" ];
  };

  systemd.user.services.flake-update-reminder = {
    Unit.Description = "Monthly reminder to update flake.lock";
    Service = {
      Type = "oneshot";
      ExecStart = "${updateReminder}/bin/flake-update-reminder";
    };
  };
  systemd.user.timers.flake-update-reminder = {
    Unit.Description = "Monthly flake.lock update reminder";
    Timer = {
      OnCalendar = "monthly";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
    Install.WantedBy = [ "timers.target" ];
  };

  systemd.user.services.restic-home-backup = {
    Unit = {
      Description = "restic backup of ~ and ~/nixos-mango/local";
      ConditionPathExists = "%h/.config/restic/env";
    };
    Service = {
      Type = "oneshot";
      EnvironmentFile = "%h/.config/restic/env";
      ExecStart = "${backup}/bin/restic-home-backup";
      Nice = 19;
      IOSchedulingClass = "idle";
      ExecStopPost = "${pkgs.bash}/bin/sh -c '[ \"$SERVICE_RESULT\" = success ] || ${notify} -u critical -a restic Backup \"Backup failed: journalctl --user -u restic-home-backup\"'";
    };
  };
  systemd.user.timers.restic-home-backup = {
    Unit.Description = "Daily restic backup (skipped until configured)";
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "30min";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
