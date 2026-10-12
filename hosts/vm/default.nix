# Machine entrypoint.
# Private files live in ../../local/ (gitignored). When absent, the public
# *.example.nix templates are used so `nix flake check` / eval still works.
# Rebuilds should use `path:.#nixos` so untracked local/ files are visible.
{ lib, ... }:
let
  root = ../..;
  localConfig = root + "/local/configuration.nix";
  localHw = root + "/local/hardware-configuration.nix";
  localSsh = root + "/local/ssh.nix";
in
{
  imports = [
    (if builtins.pathExists localConfig then localConfig else ./configuration.example.nix)
    (if builtins.pathExists localHw then localHw else ./hardware-configuration.example.nix)
  ]
  ++ lib.optional (builtins.pathExists localSsh) localSsh;
}
