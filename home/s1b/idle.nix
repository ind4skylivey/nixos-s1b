# hypridle: aviso a los 5 min, bloquea a los 10. Sin suspender (VM).
# (Sin brightnessctl: virtio-gpu no expone backlight.)
{ pkgs, ... }:
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        ignore_dbus_inhibit = false;
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "${pkgs.libnotify}/bin/notify-send -u low -a hypridle 'Screen' 'Locking in 5 minutes…'";
        }
        {
          timeout = 600;
          on-timeout = "loginctl lock-session";
        }
      ];
    };
  };
}
