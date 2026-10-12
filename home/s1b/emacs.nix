# Emacs (pgtk) + Doom. Emacs y los paquetes con partes nativas (vterm, gramáticas
# tree-sitter) salen del caché de nixpkgs; Doom se instala aparte con
# `doom-install` (versión fijada) y su config privada vive en ./doom/.
# Desde Nix solo se generan la paleta (stylix-colors.el) y el tema
# doom-neon-s1b-hk, así que cambiar de especialización recolorea Emacs.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  c = config.lib.stylix.colors; # hex sin '#'
  fonts = config.stylix.fonts;
  emacsDir = "${config.xdg.configHome}/emacs";

  # Doom fijado: los nombres de módulo de ./doom/init.el (dashboard,
  # smooth-scroll, org +pretty → org-modern…) corresponden a esta versión.
  doomRev = "v2.2.4";

  # Un poco más opaco que kitty: código legible sobre el wallpaper.
  alpha = lib.min 100 (builtins.floor ((config.stylix.opacity.terminal + 0.02) * 100 + 0.5));

  bases = [
    "base00"
    "base01"
    "base02"
    "base03"
    "base04"
    "base05"
    "base06"
    "base07"
    "base08"
    "base09"
    "base0A"
    "base0B"
    "base0C"
    "base0D"
    "base0E"
    "base0F"
  ];
  h = b: "#${c.${b}}";

  stylixColors = ''
    ;;; stylix-colors.el --- Generado por Home Manager (emacs.nix); no editar -*- lexical-binding: t; -*-
    ;; Paleta: ${c.scheme or "stylix"}

    (defconst s1b/colors
      '(${lib.concatMapStringsSep "\n    " (b: ''(${b} . "${h b}")'') bases})
      "Paleta base16 activa de stylix.")

    (defun s1b/color (base)
      "Color hex de BASE (símbolo, p. ej. `base0D') en la paleta activa."
      (alist-get base s1b/colors))

    (defconst s1b/alpha-background ${toString alpha}
      "Opacidad del fondo del frame (0-100), derivada de stylix.opacity.")

    (defconst s1b/font-mono "${fonts.monospace.name}")
    (defconst s1b/font-sans "${fonts.sansSerif.name}")
    (defconst s1b/font-size ${toString fonts.sizes.terminal}.0
      "Tamaño en puntos; el mismo que kitty.")

    (provide 'stylix-colors)
    ;;; stylix-colors.el ends here
  '';

  # Tema doom-themes con la paleta de stylix. Los grises intermedios y las
  # variantes oscuras se calculan en elisp con doom-darken/doom-lighten.
  theme = ''
    ;;; doom-neon-s1b-hk-theme.el --- Generado por Home Manager (emacs.nix); no editar -*- lexical-binding: t; no-byte-compile: t; -*-
    ;; Paleta: ${c.scheme or "stylix"} (base16, vía stylix)
    (require 'doom-themes)

    (defgroup doom-neon-s1b-hk-theme nil
      "Opciones del tema doom-neon-s1b-hk."
      :group 'doom-themes)

    (def-doom-theme doom-neon-s1b-hk
      "Morado/rojo cyberpunk, tranquilo y legible, desde stylix."
      :family 'doom-neon-s1b-hk
      :background-mode 'dark

      ;; name        default                                   256         16
      ((bg         '("${h "base00"}" "black" "black"))
       (fg         '("${h "base05"}" "#dfdfdf" "brightwhite"))
       (bg-alt     `(,(doom-darken "${h "base00"}" 0.18) "black" "black"))
       (fg-alt     '("${h "base04"}" "#bfbfbf" "white"))

       (base0      `(,(doom-darken "${h "base00"}" 0.35) "black" "black"))
       (base1      `(,(doom-darken "${h "base00"}" 0.18) "#1e1e1e" "brightblack"))
       (base2      '("${h "base00"}" "#2e2e2e" "brightblack"))
       (base3      '("${h "base01"}" "#262626" "brightblack"))
       (base4      '("${h "base02"}" "#3f3f3f" "brightblack"))
       (base5      '("${h "base03"}" "#525252" "brightblack"))
       (base6      `(,(doom-blend "${h "base03"}" "${h "base04"}" 0.5) "#6b6b6b" "brightblack"))
       (base7      '("${h "base04"}" "#979797" "brightblack"))
       (base8      '("${h "base07"}" "#dfdfdf" "white"))

       (grey       base5)
       (red        '("${h "base08"}" "#ff6655" "red"))
       (orange     '("${h "base09"}" "#dd8844" "brightred"))
       (green      '("${h "base0B"}" "#99bb66" "green"))
       (teal       `(,(doom-blend "${h "base0B"}" "${h "base0C"}" 0.5) "#44b9b1" "brightgreen"))
       (yellow     '("${h "base0A"}" "#ECBE7B" "yellow"))
       (blue       '("${h "base0D"}" "#51afef" "brightblue"))
       (dark-blue  `(,(doom-darken "${h "base0D"}" 0.3) "#2257A0" "blue"))
       (magenta    '("${h "base0E"}" "#c678dd" "brightmagenta"))
       (violet     `(,(doom-lighten "${h "base0D"}" 0.25) "#a9a1e1" "magenta"))
       (cyan       '("${h "base0C"}" "#46D9FF" "brightcyan"))
       (dark-cyan  `(,(doom-darken "${h "base0C"}" 0.3) "#5699AF" "cyan"))
       (crimson    '("${h "base0F"}" "#c4385d" "red"))

       ;; categorías de caras
       (highlight      magenta)
       (vertical-bar   base4)
       (selection      base4)
       (builtin        violet)
       (comments       (doom-lighten base5 0.18))
       (doc-comments   (doom-lighten base5 0.32))
       (constants      orange)
       (functions      blue)
       (keywords       magenta)
       (methods        cyan)
       (operators      cyan)
       (type           yellow)
       (strings        green)
       (variables      (doom-lighten blue 0.45))
       (numbers        orange)
       (region         base4)
       (error          red)
       (warning        yellow)
       (success        green)
       (vc-modified    orange)
       (vc-added       green)
       (vc-deleted     red)

       ;; modeline
       (modeline-fg          fg)
       (modeline-fg-alt      base7)
       (modeline-bg          base3)
       (modeline-bg-alt      bg-alt)
       (modeline-bg-inactive bg-alt)
       (modeline-bg-inactive-alt bg-alt))

      ;;;; caras
      (((line-number &override) :foreground base5)
       ((line-number-current-line &override) :foreground magenta :weight 'bold)
       (cursor :background magenta)
       (font-lock-comment-face :foreground comments :slant 'italic)
       (font-lock-doc-face :foreground doc-comments :slant 'italic)
       (font-lock-keyword-face :foreground keywords :weight 'semi-bold)
       (show-paren-match :foreground bg :background magenta :weight 'bold)
       (vertical-border :foreground base4 :background base4)
       (minibuffer-prompt :foreground magenta :weight 'bold)
       (link :foreground cyan :underline t)
       (fringe :background bg)

       ;; modeline
       (mode-line :background modeline-bg :foreground modeline-fg
                  :box `(:line-width 4 :color ,base3))
       (mode-line-inactive :background modeline-bg-inactive :foreground modeline-fg-alt
                           :box `(:line-width 4 :color ,bg-alt))
       (mode-line-emphasis :foreground magenta)
       (doom-modeline-bar :background magenta)
       (doom-modeline-bar-inactive :background base4)
       (doom-modeline-buffer-file :foreground fg :weight 'bold)
       (doom-modeline-buffer-modified :foreground red :weight 'bold)
       (doom-modeline-buffer-path :foreground violet)
       (doom-modeline-project-dir :foreground blue :weight 'bold)
       (doom-modeline-info :foreground green)
       (doom-modeline-evil-normal-state :foreground blue :weight 'bold)
       (doom-modeline-evil-insert-state :foreground green :weight 'bold)
       (doom-modeline-evil-visual-state :foreground magenta :weight 'bold)
       (doom-modeline-evil-replace-state :foreground red :weight 'bold)
       (doom-modeline-evil-emacs-state :foreground orange :weight 'bold)
       (doom-modeline-evil-motion-state :foreground cyan :weight 'bold)
       (doom-modeline-evil-operator-state :foreground yellow :weight 'bold)

       ;; solaire: buffers auxiliares un tono más oscuros
       (solaire-default-face :background bg-alt)
       (solaire-hl-line-face :background base3)
       (solaire-mode-line-face :inherit 'mode-line)
       (solaire-mode-line-inactive-face :inherit 'mode-line-inactive)

       ;; dashboard
       (+dashboard-banner :foreground magenta :weight 'bold)
       (+dashboard-menu-title :foreground fg)
       (+dashboard-menu-desc :foreground violet)
       (+dashboard-loaded :foreground base6 :slant 'italic)
       (+dashboard-footer-icon :foreground magenta)

       ;; completado / posframe
       (vertico-current :background base3 :foreground magenta :weight 'bold :extend t)
       (vertico-posframe-border :background blue)
       (vertico-posframe :background bg-alt)
       (orderless-match-face-0 :foreground magenta :weight 'bold)
       (orderless-match-face-1 :foreground blue :weight 'bold)
       (orderless-match-face-2 :foreground cyan :weight 'bold)
       (orderless-match-face-3 :foreground yellow :weight 'bold)
       (marginalia-documentation :foreground base7 :slant 'italic)
       (marginalia-key :foreground magenta)
       (consult-file :foreground fg)
       (completions-common-part :foreground magenta)
       (corfu-current :background base3 :foreground magenta)
       (corfu-border :background blue)

       ;; rainbow-delimiters
       (rainbow-delimiters-depth-1-face :foreground magenta)
       (rainbow-delimiters-depth-2-face :foreground blue)
       (rainbow-delimiters-depth-3-face :foreground cyan)
       (rainbow-delimiters-depth-4-face :foreground yellow)
       (rainbow-delimiters-depth-5-face :foreground green)
       (rainbow-delimiters-depth-6-face :foreground orange)
       (rainbow-delimiters-depth-7-face :foreground violet)
       (rainbow-delimiters-depth-8-face :foreground red)
       (rainbow-delimiters-depth-9-face :foreground teal)
       (rainbow-delimiters-unmatched-face :foreground red :weight 'bold :inverse-video t)

       ;; evil / búsqueda
       (evil-ex-substitute-replacement :foreground magenta :strike-through nil :inherit 'evil-ex-substitute-matches)
       (evil-goggles-default-face :background (doom-blend magenta bg 0.35))
       (isearch :foreground bg :background magenta :weight 'bold)
       (lazy-highlight :foreground fg :background (doom-blend blue bg 0.35))
       (nav-flash-face :background (doom-blend magenta bg 0.3) :extend t)

       ;; dired / dirvish
       (dired-directory :foreground blue :weight 'bold)
       (dired-header :foreground magenta :weight 'bold)
       (dirvish-hl-line :background base3 :extend t)

       ;; org
       (org-document-title :foreground magenta :weight 'bold :height 1.5)
       (org-level-1 :foreground blue :weight 'bold :height 1.3)
       (org-level-2 :foreground magenta :weight 'bold :height 1.2)
       (org-level-3 :foreground cyan :weight 'semi-bold :height 1.1)
       (org-level-4 :foreground violet :weight 'semi-bold)
       (org-level-5 :foreground yellow)
       (org-level-6 :foreground green)
       (org-block :background bg-alt :extend t)
       (org-block-begin-line :foreground base6 :background bg-alt :slant 'italic :extend t)
       (org-block-end-line :inherit 'org-block-begin-line)
       (org-code :foreground orange)
       (org-verbatim :foreground green)
       (org-link :foreground cyan :underline t)
       (org-todo :foreground magenta :weight 'bold)
       (org-done :foreground base6 :weight 'bold)
       (org-headline-done :foreground base6)
       (org-ellipsis :foreground base6 :underline nil)
       (org-modern-tag :foreground bg :background violet)
       (org-modern-done :foreground bg :background base6)

       ;; markdown
       (markdown-header-face-1 :inherit 'org-level-1)
       (markdown-header-face-2 :inherit 'org-level-2)
       (markdown-header-face-3 :inherit 'org-level-3)
       (markdown-code-face :background bg-alt :extend t))

      ;;;; variables
      ())

    ;;; doom-neon-s1b-hk-theme.el ends here
  '';

  # Instala Doom a mano (clona la versión fijada y ejecuta `doom install`);
  # si ya está instalado, hace `doom sync`. No corre solo: el primer sync
  # descarga y compila ~150 paquetes.
  doomInstall = pkgs.writeShellApplication {
    name = "doom-install";
    runtimeInputs = with pkgs; [
      git
      coreutils
    ];
    text = ''
      # git.nix reescribe https://github.com/ a SSH; Doom clona ~150 repos
      # públicos, así que aquí van por https anónimo, sin tocar la llave.
      export GIT_CONFIG_GLOBAL=/dev/null
      if [[ -x "${emacsDir}/bin/doom" ]]; then
        echo "Doom is already installed in ${emacsDir}. Running 'doom sync'…"
        exec "${emacsDir}/bin/doom" sync "$@"
      fi
      if [[ -e "${emacsDir}" ]]; then
        echo "${emacsDir} exists but is not Doom. Move it away first." >&2
        exit 1
      fi
      git clone --depth 1 --branch ${doomRev} \
        --recurse-submodules --shallow-submodules \
        https://github.com/doomemacs/doomemacs "${emacsDir}"
      # La config ya viene de Home Manager (~/.config/doom). Sin archivo de
      # envvars: en NixOS se queda viejo con cada rebuild.
      exec "${emacsDir}/bin/doom" install --no-config --no-env "$@"
    '';
  };
in
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    # Precompilados en el caché: Doom los usa en vez de compilarlos en la VM.
    extraPackages = epkgs: [
      epkgs.vterm
      (epkgs.treesit-grammars.with-grammars (
        g: with g; [
          tree-sitter-bash
          tree-sitter-c
          tree-sitter-css
          tree-sitter-elisp
          tree-sitter-html
          tree-sitter-javascript
          tree-sitter-json
          tree-sitter-lua
          tree-sitter-markdown
          tree-sitter-markdown-inline
          tree-sitter-nix
          tree-sitter-php
          tree-sitter-python
          tree-sitter-rust
          tree-sitter-toml
          tree-sitter-yaml
        ]
      ))
    ];
  };

  # Doom carga su propio tema; el de stylix (default.el) lo pisaría junto
  # con la transparencia.
  stylix.targets.emacs.enable = false;

  home.sessionPath = [ "${emacsDir}/bin" ];
  programs.bash.shellAliases.doom-sync = "doom-install";

  home.packages = with pkgs; [
    doomInstall
    # dependencias de Doom
    git
    ripgrep
    fd
    shellcheck
  ];

  xdg.configFile = {
    "doom/init.el".source = ./doom/init.el;
    "doom/packages.el".source = ./doom/packages.el;
    "doom/config.el".source = ./doom/config.el;
    "doom/stylix-colors.el".text = stylixColors;
    "doom/themes/doom-neon-s1b-hk-theme.el".text = theme;
  };
}
