# Políticas gestionadas de Chromium para Helium: start page local al abrir y
# en cada pestaña nueva. Helium lee /etc/chromium/policies/managed/*.json
# (stylix ya deja ahí extra.json con BrowserThemeColor; este archivo es aparte).
# La página la sirve el servicio de usuario de home/s1b/startpage.nix.
{ ... }:
let
  url = "http://127.0.0.1:7777/";
in
{
  environment.etc."chromium/policies/managed/startpage.json".text = builtins.toJSON {
    HomepageLocation = url;
    HomepageIsNewTabPage = false;
    ShowHomeButton = true;
    RestoreOnStartup = 4;
    RestoreOnStartupURLs = [ url ];
    NewTabPageLocation = url;
  };
}
