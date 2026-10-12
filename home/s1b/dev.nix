# Desarrollo y utilidades de terminal: tmux, direnv, Emacs (Doom), CLI.
# bat, fzf, lazygit y tmux los tematiza stylix con la paleta activa.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  c = config.lib.stylix.colors.withHashtag;
  emacsDir = "${config.xdg.configHome}/emacs";

  # Instala Doom Emacs a mano (clona y ejecuta `doom install`). No corre solo.
  doomInstall = pkgs.writeShellApplication {
    name = "doom-install";
    runtimeInputs = with pkgs; [
      git
      coreutils
    ];
    text = ''
      if [[ -x "${emacsDir}/bin/doom" ]]; then
        echo "Doom is already installed in ${emacsDir}. Running 'doom sync'…"
        exec "${emacsDir}/bin/doom" sync
      fi
      if [[ -e "${emacsDir}" ]]; then
        echo "${emacsDir} exists but is not Doom. Move it away first." >&2
        exit 1
      fi
      git clone --depth 1 https://github.com/doomemacs/doomemacs "${emacsDir}"
      exec "${emacsDir}/bin/doom" install "$@"
    '';
  };
in
{
  # ------------------------------------------------------------ Emacs / Doom
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
  };
  home.sessionPath = [ "${emacsDir}/bin" ];

  home.packages = with pkgs; [
    doomInstall
    # dependencias de Doom
    git
    ripgrep
    fd
    cmake
    gnumake
    gcc
    libtool
    shellcheck
    # terminal
    wl-clipboard
  ];

  # ------------------------------------------------------------ tmux
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    mouse = true;
    keyMode = "vi";
    baseIndex = 1;
    escapeTime = 10;
    historyLimit = 50000;
    terminal = "tmux-256color";
    extraConfig = ''
      set -ag terminal-overrides ",xterm-kitty:RGB"
      set -g renumber-windows on
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind r source-file ~/.config/tmux/tmux.conf \; display "tmux reloaded"
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel "wl-copy"

      # Barra de estado con la paleta
      set -g status-position bottom
      set -g status-style "bg=${c.base01},fg=${c.base05}"
      set -g status-left "#[bg=${c.base0D},fg=${c.base00},bold]  #S #[bg=${c.base01}] "
      set -g status-right "#[fg=${c.base0E}]%H:%M #[fg=${c.base04}]· %a %d %b "
      set -g window-status-format "#[fg=${c.base04}] #I:#W "
      set -g window-status-current-format "#[bg=${c.base02},fg=${c.base0D},bold] #I:#W "
      set -g pane-border-style "fg=${c.base02}"
      set -g pane-active-border-style "fg=${c.base0D}"
      set -g message-style "bg=${c.base02},fg=${c.base07}"
    '';
  };
  # Usamos nuestra barra; stylix solo pondría otro tema encima.
  stylix.targets.tmux.enable = false;

  # ------------------------------------------------------------ direnv
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  # ------------------------------------------------------------ CLI
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    defaultCommand = "fd --type f --hidden --exclude .git";
  };
  programs.bat.enable = true;
  programs.lazygit.enable = true;
  programs.tealdeer = {
    enable = true;
    settings.updates.auto_update = true;
  };

  # nix-index + comma (base de datos precompilada, sin `nix-index` local).
  programs.nix-index = {
    enable = true;
    enableBashIntegration = true;
  };
  programs.nix-index-database.comma.enable = true;

  programs.bash.shellAliases = {
    # path: sigue viendo archivos sin trackear; con git el flake solo ve lo
    # commiteado/staged — haz `git add` antes de rebuild si tocaste archivos nuevos.
    rebuild = "sudo -n /run/current-system/sw/bin/nixos-rebuild switch --flake path:${config.home.homeDirectory}/nixos-mango#nixos";
    lg = "lazygit";
    nix-lint = "statix check ${config.home.homeDirectory}/nixos-mango && deadnix ${config.home.homeDirectory}/nixos-mango";
    ns = "ns"; # nix-search-tv + fzf (paquete del sistema)
  };

  programs.git = {
    enable = true;
    userName = "ind4skylivey";
    userEmail = "ind4skylivey@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      core.quotepath = false;
    };
  };
}
