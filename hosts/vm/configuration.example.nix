# Example machine config — copy to ../../local/configuration.nix and edit.
# This file is what the public flake evaluates when local/ is absent.
{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [ ];

  boot.loader.grub.enable = true;
  # boot.loader.grub.device = "/dev/vda"; # set for your disk, or use systemd-boot
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = false;

  networking.hostName = "nixos"; # change me

  networking.networkmanager.enable = true;

  # time.timeZone = "UTC"; # e.g. "Europe/Berlin"
  # i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Single username used by Home Manager (must match flake.nix / home/<user>).
  users.users."s1b" = {
    isNormalUser = true;
    description = "LiveY"; # display name only
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05";
}
