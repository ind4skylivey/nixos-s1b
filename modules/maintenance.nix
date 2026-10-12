# Mantenimiento del sistema: store deduplicado, zram y nix-ld.
# Las actualizaciones NO son automáticas: home/s1b/maintenance.nix avisa una
# vez al mes para hacer `nix flake update` + rebuild a mano.
{ pkgs, ... }:
{
  # Archivos idénticos del store como hardlinks: al construir y, por si
  # acaso, una pasada semanal.
  nix.settings.auto-optimise-store = true;
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  # Swap comprimido en RAM: ayuda con builds grandes en una VM de 6 GB. El swap
  # en disco (si hay) queda detrás por prioridad.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # Binarios genéricos de Linux (descargas, LSP o CLIs precompilados) que
  # esperan /lib64/ld-linux-x86-64.so.2 y librerías del sistema.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      zstd
      openssl
      curl
      glib
      icu
      libxml2
      expat
      nss
      libGL
      libxkbcommon
      wayland
      fuse3
    ];
  };
}
