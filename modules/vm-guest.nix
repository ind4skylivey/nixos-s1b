# Integración con QEMU/KVM (virt-manager, Video Virtio + virgl, Spice).
{ lib, ... }:
{
  # Agente QEMU (apagado limpio, info de IP en virt-manager, etc.).
  services.qemuGuest.enable = true;

  # Agente Spice: portapapeles compartido y ajuste de resolución.
  # El demonio corre como servicio del sistema; el agente de usuario
  # (spice-vdagent) se lanza desde el autostart de mango (home/s1b/mango.nix).
  services.spice-vdagentd.enable = true;

  # Mesa con virgl para la aceleración 3D de virtio-gpu.
  hardware.graphics.enable = true;

  environment.sessionVariables = {
    # En VMs con virtio-gpu el cursor por hardware suele fallar en wlroots.
    WLR_NO_HARDWARE_CURSORS = lib.mkDefault "1";
    # Apps Electron/Chromium en Wayland nativo.
    NIXOS_OZONE_WL = lib.mkDefault "1";
  };
}
