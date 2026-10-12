# Inicio de sesión en modo texto: greetd + tuigreet (tema Neon S1B Hk + doom fire).
{ config, pkgs, ... }:
let
  mangoBin = "${config.programs.mango.package}/bin/mango";
  theme = "border=magenta;text=white;time=magenta;container=black;title=magenta;greet=magenta;prompt=white;input=magenta;action=white;button=red";
in
{
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --time-format '%H:%M · %A %d %b' --remember --asterisks --user-menu --greeting 'hi LiveY · mango @ nixos' --theme '${theme}' --doom-colors '#b57bff,#ee6ac8,#ff4f72' --window-padding 1 --container-padding 2 --cmd ${mangoBin}";
      user = "greeter";
    };
  };
}
