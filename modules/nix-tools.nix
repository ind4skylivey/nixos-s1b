# Herramientas Nix del día a día: nh (switch/clean), nom, nvd, lint, search, sops.
# Nota: `nh os switch` llama a sudo para switch-to-configuration (pide
# contraseña: la regla NOPASSWD solo cubre nixos-rebuild). El alias `rebuild`
# usa nixos-rebuild para seguir sin contraseña.
{ pkgs, ... }:
{
  programs.nh = {
    enable = true;
    flake = "/home/s1b/nixos-mango";
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 10 --keep-since 7d";
    };
  };

  # Builds locales contenidos: la VM tiene 8 GB y compilar en paralelo la
  # dejaba sin memoria (swap). Se prioriza el caché binario.
  nix.settings = {
    max-jobs = 2;
    cores = 2;
  };

  # nix-index (vía nix-index-database en Home Manager) reemplaza a esto.
  programs.command-not-found.enable = false;

  environment.systemPackages = with pkgs; [
    nix-output-monitor
    nvd
    # LSP / format
    nixd
    nil
    nixfmt # RFC style (alias de nixfmt-rfc-style en 26.05)
    # lint
    statix
    deadnix
    # explore / compare / fetch
    nix-tree
    nix-diff
    nurl
    # docs / search
    manix
    optnix
    nix-search-tv
    # secrets
    sops
    age
    # wrapper fzf para nix-search-tv
    (writeShellApplication {
      name = "ns";
      runtimeInputs = [
        fzf
        nix-search-tv
        gawk
        coreutils
      ];
      text = ''
        # Búsqueda difusa de paquetes/opciones (nix-search-tv + fzf).
        exec nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history --layout reverse
      '';
    })
  ];
}
