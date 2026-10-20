# Compositor mango (módulo NixOS oficial de mangowm/mango).
{ lib, pkgs, ... }:
{
  programs.mango.enable = true;

  # Portales: wlr primero (captura), gtk de respaldo; evita buscar Mutter.
  xdg.portal.config.common.default = [
    "wlr"
    "gtk"
  ];

  # Necesario para que home-manager/stylix escriban la configuración GTK (dconf).
  programs.dconf.enable = lib.mkDefault true;

  # Audio y red. mkDefault: si el configuration.nix del instalador ya los
  # define, se respeta lo suyo.
  services.pulseaudio.enable = lib.mkDefault false;
  security.rtkit.enable = lib.mkDefault true;
  services.pipewire = {
    enable = lib.mkDefault true;
    alsa.enable = lib.mkDefault true;
    pulse.enable = lib.mkDefault true;
    wireplumber.enable = lib.mkDefault true;
  };
  networking.networkmanager.enable = lib.mkDefault true;

  fonts = {
    enableDefaultPackages = lib.mkDefault true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      maple-mono.NF
      inter
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.symbols-only # respaldo de iconos Nerd Font
    ];
  };

  # PAM para hyprlock (bloqueo de pantalla, ver home/s1b/lock.nix).
  security.pam.services.hyprlock = { };

  # Herramientas mínimas útiles en todo el sistema.
  # Montajes/unidades y trash para gestores de archivos (Strata usa GIO/GVfs).
  services.gvfs.enable = lib.mkDefault true;
  services.udisks2.enable = lib.mkDefault true;

  environment.systemPackages = with pkgs; [
    git
    wl-clipboard
    xdg-utils
  ];
}
