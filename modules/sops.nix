# sops-nix: age-encrypted secrets.
# Private key (NEVER in the repo): ~/.config/sops/age/keys.txt
# Regenerate: age-keygen -o ~/.config/sops/age/keys.txt
# Put the public key in .sops.yaml and re-encrypt secrets/*.yaml
{ config, ... }:
{
  sops = {
    defaultSopsFile = ../secrets/example.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/s1b/.config/sops/age/keys.txt";
    # Dummy secret to prove the pipeline (ciphertext in secrets/example.yaml).
    secrets.example_dummy = {
      owner = "s1b";
      group = "users";
      mode = "0400";
    };
  };

  # Path of the dummy secret as a session env var (demo only; not for real secrets).
  environment.sessionVariables.SOPS_EXAMPLE_DUMMY = config.sops.secrets.example_dummy.path;
}
