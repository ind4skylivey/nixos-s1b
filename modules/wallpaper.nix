# Fondos reproducibles (importado como función: `import ./wallpaper.nix pkgs`).
# Base: "red sun over purple mountains" (wallhaven g8dqvl, 3840x2160).
# - wallpaper: suavizado horizontal (quita las scanlines del original),
#   más luminoso y saturado (morado/rojo) con viñeta muy suave -> escritorio calmado y legible.
# - lock: versión desenfocada y más oscura para hyprlock (sin blur en GPU).
pkgs:
let
  src = pkgs.fetchurl {
    url = "https://w.wallhaven.cc/full/g8/wallhaven-g8dqvl.jpg";
    hash = "sha256-T+l7uYVtwzydG45M70MfLF3QXH4C05bVdbmNAaE8nGY=";
  };
  im = name: script: pkgs.runCommand name { nativeBuildInputs = [ pkgs.imagemagick ]; } script;
in
rec {
  wallpaper = im "neon-s1b-hk-wallpaper.png" ''
    magick ${src} -morphology Convolve Blur:0x4 \
      -resize 2560x1440^ -gravity center -extent 2560x1440 \
      -modulate 112,118,100 -brightness-contrast 6x0 \
      \( -size 2560x1440 radial-gradient:'#ffffff'-'#c8b8d8' \) \
      -compose multiply -composite \
      -depth 8 "$out"
  '';

  lock = im "neon-s1b-hk-lock.png" ''
    magick ${wallpaper} -resize 50% -blur 0x18 -resize 200% \
      -modulate 78,110,100 \
      -depth 8 "$out"
  '';
}
