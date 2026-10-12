# Start page de Helium (inicio + nueva pestaña).
# - Archivos estáticos en ./startpage; colors.css se genera desde la paleta
#   de stylix, así sigue a las especializaciones de tema.
#   El fondo (bg.jpg) es una imagen fija del repo, no el wallpaper de stylix.
# - Se instala en ~/.local/share/startpage y se sirve en 127.0.0.1:7777 con
#   un servicio de usuario (NewTabPageLocation no acepta file://).
# - Las políticas de Chromium que lo apuntan viven en modules/startpage.nix.
{
  config,
  pkgs,
  ...
}:
let
  c = config.lib.stylix.colors.withHashtag;
  port = 7777;
  dir = "${config.xdg.dataHome}/startpage";

  colors = pkgs.writeText "startpage-colors.css" ''
    :root {
      --base00: ${c.base00}; --base01: ${c.base01}; --base02: ${c.base02}; --base03: ${c.base03};
      --base04: ${c.base04}; --base05: ${c.base05}; --base06: ${c.base06}; --base07: ${c.base07};
      --base08: ${c.base08}; --base09: ${c.base09}; --base0A: ${c.base0A}; --base0B: ${c.base0B};
      --base0C: ${c.base0C}; --base0D: ${c.base0D}; --base0E: ${c.base0E}; --base0F: ${c.base0F};
      --font-mono: "${config.stylix.fonts.monospace.name}";
    }
  '';

  site = pkgs.runCommandLocal "startpage" { } ''
    mkdir -p $out
    cp ${./startpage}/* $out/
    cp ${colors} $out/colors.css
    # Cache-bust: Nix store files have a 1970 mtime, so Chromium caches them forever.
    chmod -R u+w $out
    v=$(basename $out | cut -c1-12)
    sed -i -E "s/(colors\.css|style\.css|app\.js)\"/\1?v=$v\"/" $out/index.html
    sed -i "s/bg\.jpg\"/bg.jpg?v=$v\"/" $out/style.css
  '';
in
{
  xdg.dataFile."startpage".source = site;

  systemd.user.services.startpage = {
    Unit = {
      Description = "Helium start page (127.0.0.1:${toString port})";
      X-Restart-Triggers = [ "${site}" ];
    };
    Service = {
      ExecStart = "${pkgs.python3}/bin/python3 -m http.server ${toString port} --bind 127.0.0.1 --directory ${dir}";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
