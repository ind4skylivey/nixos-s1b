# Home Manager para s1b.
{ pkgs, ... }:
{
  imports = [
    ./mango.nix
    ./waybar.nix
    ./rofi.nix
    ./swaync.nix
    ./kitty.nix
    ./shell.nix
    ./lock.nix
    ./idle.nix
    ./wlogout.nix
    ./wallpapers.nix
    ./themes.nix
    ./apps.nix
    ./nvim.nix
    ./desktop-apps.nix
    ./dev.nix
    ./git.nix
    ./screenshots.nix
  ];

  home.username = "s1b";
  home.homeDirectory = "/home/s1b";
  home.stateVersion = "26.05";

  wayland.systemd.target = "mango-session.target";

  stylix.targets = {
    waybar.enable = false;
    rofi.enable = false;
    swaync.enable = false;
    starship.enable = false;
  };

  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
    pavucontrol
    libnotify
    jq
    wlr-randr
  ];

  programs.home-manager.enable = true;
}
