# Local (private) machine files

Copy examples into `local/` on each machine. That directory is gitignored.

```sh
mkdir -p local
cp hosts/vm/configuration.example.nix        local/configuration.nix
cp hosts/vm/hardware-configuration.example.nix local/hardware-configuration.nix
cp modules/ssh.example.nix                   local/ssh.nix
```

Replace hardware with `nixos-generate-config` output (disk ids stay private).
Put SSH public keys and any NOPASSWD sudo rules only in `local/ssh.nix`.

Rebuild with `path:` so Nix sees gitignored files:

```sh
sudo nixos-rebuild switch --flake path:.#nixos
```
