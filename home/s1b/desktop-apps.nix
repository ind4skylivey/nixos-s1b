# Apps gráficas: navegador Helium y gestor de archivos Strata.
# - Helium: flake comunitario oxcl/nix-flake-helium-browser (repaquetea el .deb
#   oficial de imputnet/helium-linux), con nixpkgs.follows → nuestro 26.05.
# - Strata: derivación local compilada desde el tag oficial (pkgs/strata).
# - imv: visor de imágenes ligero (Wayland) para abrir fotos desde Strata.
# Todos instalan su .desktop, así que rofi (drun) los lista.
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  helium = inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.helium.override {
    # Modo oscuro de la UI y de las páginas (prefers-color-scheme: dark).
    flags = [
      "--force-dark-mode"
      "--enable-features=WebUIDarkMode"
    ];
  };
  # Strata se compila con rustc de nixos-unstable (>= 1.96) y librerías de 26.05.
  unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  # nixpkgs "limpio" (sin overlays de stylix, que cambian gtksourceview por
  # paleta): así Strata se compila una sola vez y no por especialización.
  base = inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  strata = base.callPackage ../../pkgs/strata/package.nix {
    rustPlatform = base.makeRustPlatform { inherit (unstable) rustc cargo; };
  };
in
{
  home.packages = [
    helium
    strata
  ];

  # Navegador y gestor de archivos por defecto.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = [ "helium.desktop" ];
      "x-scheme-handler/https" = [ "helium.desktop" ];
      "x-scheme-handler/about" = [ "helium.desktop" ];
      "x-scheme-handler/unknown" = [ "helium.desktop" ];
      "text/html" = [ "helium.desktop" ];
      "application/xhtml+xml" = [ "helium.desktop" ];
      "inode/directory" = [ "io.github.lgse.Strata.desktop" ];
    }
    // lib.genAttrs [
      "image/jpeg"
      "image/png"
      "image/webp"
      "image/gif"
      "image/avif"
      "image/svg+xml"
      "image/bmp"
      "image/tiff"
    ] (_: [ "imv.desktop" ]);
  };

  # Visor de imágenes, con fondo de la paleta.
  programs.imv = {
    enable = true;
    settings.options = {
      background = lib.mkDefault config.lib.stylix.colors.base00;
      overlay_font = lib.mkDefault "${config.stylix.fonts.monospace.name}:11";
    };
  };

  home.sessionVariables.BROWSER = "helium";
}
