# Interfaz en inglés (fechas incluidas). El teclado y la zona horaria no se tocan.
{ lib, ... }:
{
  i18n.defaultLocale = lib.mkForce "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME = lib.mkForce "en_US.UTF-8";
    LC_MESSAGES = lib.mkForce "en_US.UTF-8";
  };
}
