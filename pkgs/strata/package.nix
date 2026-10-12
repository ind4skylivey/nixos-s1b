# Strata (lgse/strata): gestor de archivos GTK4 "keyboard-first".
# No está en nixpkgs (26.05 ni unstable). Se compila desde el tag oficial porque
# el sandbox de previews (bubblewrap) fija sus rutas AL COMPILAR
# (STRATA_SANDBOX_*): el binario precompilado busca /usr y /usr/bin/prlimit,
# que no existen en NixOS, y las previews fallan "cerradas" (sin imagen).
{
  lib,
  rustPlatform,
  fetchFromGitHub,
  runCommand,
  pkg-config,
  wrapGAppsHook4,
  glib,
  gtk4,
  gtksourceview5,
  poppler,
  fontconfig,
  gdk-pixbuf,
  webp-pixbuf-loader,
  librsvg,
  gst_all_1,
  bubblewrap,
  util-linux,
  coreutils,
  ffmpeg,
  ffmpegthumbnailer,
  imagemagick,
  libraw,
  xdg-utils,
}:
let
  # loaders.cache para los helpers del sandbox: PNG/JPEG van integrados en
  # gdk-pixbuf; se añaden WebP y SVG.
  pixbufCache = runCommand "strata-gdk-pixbuf-loaders" { } ''
    mkdir -p $out
    ${lib.getDev gdk-pixbuf}/bin/gdk-pixbuf-query-loaders \
      ${gdk-pixbuf}/lib/gdk-pixbuf-2.0/2.10.0/loaders/*.so \
      ${webp-pixbuf-loader}/lib/gdk-pixbuf-2.0/2.10.0/loaders/*.so \
      ${librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders/*.so \
      > $out/loaders.cache
  '';

  # Herramientas visibles DENTRO del sandbox (se compilan en el ejecutable).
  previewTools = [
    ffmpeg
    ffmpegthumbnailer
    imagemagick
    libraw
    util-linux
    coreutils
    fontconfig
  ];
  # Herramientas de confianza que el proceso principal puede lanzar (bwrap…).
  trustedTools = [
    bubblewrap
    coreutils
    xdg-utils
  ]
  ++ previewTools;

  gstPlugins = with gst_all_1; [
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-libav
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "strata";
  version = "0.21.0";

  src = fetchFromGitHub {
    owner = "lgse";
    repo = "strata";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RSTEgtfDYYGxXef1J22NMGpmgjObg3T6APZqfSyfNPY=";
  };

  cargoHash = "sha256-0nMfswOfyXiwIWF0Xne61jGwPdU/gMo6Wt6JGZEfrJw=";

  # Activación de escritorio/portal: usar el wrapper de Nix, no .strata-wrapped.
  patches = [ ./wrapper-aware-activation.patch ];

  # Upstream ignora PATH al buscar herramientas de confianza; se añaden rutas
  # inmutables del store detrás de las de NixOS (/run/wrappers, sw/bin).
  postPatch = ''
    substituteInPlace src/trusted_command.rs \
      --replace-fail '    "/run/current-system/profile/bin",' \
        '    "/run/current-system/profile/bin",
    ${lib.concatMapStringsSep "\n" (p: "    \"${lib.getBin p}/bin\",") trustedTools}'
  '';

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
    glib
  ];
  buildInputs = [
    gtk4
    gtksourceview5
    poppler
    fontconfig
    gdk-pixbuf
    gst_all_1.gstreamer
  ]
  ++ gstPlugins;

  env = {
    STRATA_BUILD_COMMIT = "v${finalAttrs.version}";
    STRATA_RELEASE_TAG = "v${finalAttrs.version}";
    STRATA_BUILD_KIND = "stable";
    STRATA_SANDBOX_ROOT = "/nix/store";
    STRATA_SANDBOX_PATH = lib.makeBinPath previewTools;
    STRATA_SANDBOX_PRLIMIT = "${lib.getBin util-linux}/bin/prlimit";
    STRATA_SANDBOX_GDK_PIXBUF_MODULE_FILE = "${pixbufCache}/loaders.cache";
    # Upstream usa lto=true + codegen-units=1 (un solo hilo, >4 GB de RAM).
    # Thin LTO compila mucho más rápido y cabe en la VM.
    CARGO_PROFILE_RELEASE_LTO = "thin";
    CARGO_PROFILE_RELEASE_CODEGEN_UNITS = "16";
  };

  # La suite de tests necesita sesión gráfica y namespaces.
  doCheck = false;

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${lib.makeSearchPath "lib/gstreamer-1.0" gstPlugins}"
      --set GDK_PIXBUF_MODULE_FILE "${pixbufCache}/loaders.cache"
    )
  '';

  postInstall = ''
    install -Dm644 data/io.github.lgse.Strata.desktop $out/share/applications/io.github.lgse.Strata.desktop
    install -Dm644 data/icons/scalable/apps/io.github.lgse.Strata.svg \
      $out/share/icons/hicolor/scalable/apps/io.github.lgse.Strata.svg
    install -Dm644 data/io.github.lgse.Strata.FileManager1.service \
      $out/share/dbus-1/services/io.github.lgse.Strata.FileManager1.service
    substituteInPlace $out/share/dbus-1/services/io.github.lgse.Strata.FileManager1.service \
      --replace-fail /usr/bin/strata $out/bin/strata
    install -Dm644 -t $out/share/doc/strata LICENSE THIRD_PARTY_LICENSES.md
  '';

  passthru = { inherit pixbufCache; };

  meta = {
    description = "Fast, keyboard-first GTK4 file manager for Linux";
    homepage = "https://github.com/lgse/strata";
    changelog = "https://github.com/lgse/strata/releases/tag/v${finalAttrs.version}";
    # App MIT; las features por defecto incluyen UnRAR (licencia propia, redistribuible).
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "strata";
  };
})
