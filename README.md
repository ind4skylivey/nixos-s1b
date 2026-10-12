# nixos-mango

NixOS flake for a Wayland VM rice (**Neon S1B Hk**):
[mango](https://github.com/mangowm/mango) 0.18 + stylix + home-manager,
inspired by [hakuspace](https://github.com/hakuimaku/hakuspace).

Maintainer: [ind4skylivey](https://github.com/ind4skylivey) · display name LiveY.

## Stack

- **NixOS 26.05** (flake) + home-manager + stylix (specialisations)
- **mango** 0.18.0 Wayland compositor
- **waybar** + **swaync** + **rofi** + **wlogout** + **hyprlock** / **hypridle**
- **kitty**, **btop**, **yazi**, **neovim** (nixd + nixfmt), Helium, Strata, **imv**
- **greetd + tuigreet** themed login
- Nix day-tools: nh, nom, nvd, nix-index/comma, nixd/nil/nixfmt, statix/deadnix,
  nix-tree, nix-diff, nurl, manix, optnix, nix-search-tv, sops-nix

## Layout

```
flake.nix
hosts/vm/
  default.nix                         picks local/ or *.example.nix
  configuration.example.nix           public template
  hardware-configuration.example.nix  public template (by-label)
modules/                              shared NixOS modules
  ssh.example.nix                     copy to local/ssh.nix
home/<user>/                          Home Manager
pkgs/strata/                          Strata file manager (source build)
secrets/                              sops-encrypted YAML only
.sops.yaml                            age public key + rules
local/                                PRIVATE — gitignored (see below)
```

## Private `local/` (required on a real machine)

Machine-specific files are **not** in git. Copy the examples and edit:

```sh
mkdir -p local
cp hosts/vm/configuration.example.nix       local/configuration.nix
cp hosts/vm/hardware-configuration.example.nix local/hardware-configuration.nix
cp modules/ssh.example.nix                  local/ssh.nix
# then paste real hardware from nixos-generate-config, SSH pubkey, etc.
```

Always rebuild with a **`path:`** flake ref so gitignored `local/` is visible:

```sh
sudo nixos-rebuild switch --flake path:.#nixos
# or the rebuild alias once Home Manager is active
```

A plain `.#nixos` / GitHub checkout **without** `local/` evaluates the public
example templates (enough to check the flake; not a full personal install).

## Keybinds (Super = Win/Meta)

Live cheatsheet: **Super+/** or **Super+F1**.

| Bind | Action |
| --- | --- |
| Super+Return / Super+Shift+Return | kitty / floating kitty |
| Super+` | named scratchpad (kitty) |
| Super+B / Super+Alt+E | Helium / Strata |
| Super+Y / Super+M / Super+Alt+N | yazi / btop / nvim |
| Super+Alt+P | Nix search (`ns`) |
| Super+D / Super+V / Super+; / Super+C | apps / clipboard / emoji / calc |
| Super+Escape | lock (hyprlock) |
| Super+Ctrl+R | reload mango |
| Super+Space / Super+Shift+Space | cycle layout / toggle floating |
| Super+h/j/k/l · Super+Shift+h/j/k/l | focus · swap |
| Super+Ctrl+h/j/k/l | resize |
| Super+1…9 · Super+Shift+1…9 · Super+Ctrl+1…9 | view / move / toggle-view tag |
| Super+Shift+S / Super+Shift+A / Super+Ctrl+S | region→clipboard / satty / fullscreen shot |

> Super+L focuses right (hjkl). Lock is **Super+Escape**. Boards without Print:
> Super+Shift+A / Super+Ctrl+S. Strata is **Super+Alt+E**.

## Browser and file manager

- **Helium** (`oxcl/nix-flake-helium-browser`): dark mode; default for `http`/`https`/`text/html`.
- **Strata**: built from upstream in `pkgs/strata` (rustc from `nixpkgs-unstable`); default for `inode/directory`.
- **imv**: default image viewer.

## Themes / wallpapers

`Super+T` switches stylix specialisations. Put personal images in
`~/Pictures/wallpapers/background/` (not in the repo). The generated Neon wallpaper
is the stylix/hyprlock fallback; `awww` rotates every 15 minutes and on Super+W.

## Aliases

`rebuild` → `nixos-rebuild switch --flake path:$HOME/nixos-mango#nixos` (passwordless
only if you enabled that in `local/ssh.nix`). `lg` → lazygit. `nix-lint` → statix+deadnix.
`ns` → nix-search-tv + fzf.

## Nix tooling

| Tool | Role |
| --- | --- |
| nh / nom / nvd | switch UI, build monitor, generation diff |
| comma + nix-index | run missing commands; package hints |
| nixd + nixfmt | Neovim LSP + format-on-save for `.nix` |
| statix / deadnix | `nix-lint` |
| nix-tree / nix-diff / nurl | closure / derivation / fetch helpers |
| manix / optnix / `ns` | option docs / fuzzy package search |

### sops-nix

Ciphertext under `secrets/*.yaml`. Age **private** key only at
`~/.config/sops/age/keys.txt` (gitignored). Rules in `.sops.yaml`. Dummy:
`secrets/example.yaml` → `/run/secrets/example_dummy`.

### Git

Flakes that are pure git checkouts only see tracked files. After adding something
new: `git add` then rebuild with `path:`.

```sh
git add -A && git commit -m "Describe the change"
rebuild
```

## Apply / rollback

```sh
cd ~/nixos-mango   # or your clone path
sudo nixos-rebuild switch --flake path:.#nixos
sudo nixos-rebuild switch --rollback
```

## Public repo notes

- No private keys, authorized_keys, disk UUIDs, hostnames of real machines, or
  personal locale/timezone live in tracked files — those go under `local/`.
- UI display name: **LiveY**. Git author for this project: **ind4skylivey**.

## Optional shells

```sh
nix develop path:.#sec
nix develop path:.#re
```
