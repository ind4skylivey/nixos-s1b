# Example hardware config — copy to ../../local/hardware-configuration.nix
# after running nixos-generate-config. Prefer by-label over raw UUIDs in commits.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "virtio_pci"
    "sr_mod"
    "virtio_blk"
  ];
  boot.initrd.kernelModules = [ "virtio_gpu" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # Prefer labels you set at install time, e.g.:
  #   e2label /dev/vda1 nixos
  #   swaplabel -L swap /dev/vda2
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # swapDevices = [{ device = "/dev/disk/by-label/swap"; }];
  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
