;;; config.el -*- lexical-binding: t; -*-
;; Config privada de Doom para LiveY. Paleta, opacidad y fuentes vienen de
;; stylix-colors.el (generado por home/s1b/emacs.nix). Este archivo no necesita
;; `doom sync`: basta con reiniciar Emacs o `SPC h r r`.

(load! "stylix-colors")

(setq user-full-name "LiveY")

;; ~/.config/doom es de solo lectura (Home Manager): customize va a ~/.local/state.
(setq custom-file
      (expand-file-name "doom/custom.el"
                        (or (getenv "XDG_STATE_HOME") "~/.local/state")))
(make-directory (file-name-directory custom-file) t)
(load custom-file 'noerror 'nomessage)


;;; Tema, fuentes y transparencia

(setq doom-theme 'doom-neon-s1b-hk)

(setq doom-font (font-spec :family s1b/font-mono :size s1b/font-size)
      doom-variable-pitch-font (font-spec :family s1b/font-sans :size s1b/font-size)
      doom-big-font (font-spec :family s1b/font-mono :size (+ s1b/font-size 8))
      doom-symbol-font (font-spec :family "Symbols Nerd Font Mono"))

(setq nerd-icons-font-family "Symbols Nerd Font Mono")

;; Solo el fondo es translúcido; el texto queda opaco (pgtk + mango).
(add-to-list 'default-frame-alist `(alpha-background . ,s1b/alpha-background))
(set-frame-parameter nil 'alpha-background s1b/alpha-background)

(defun s1b/toggle-transparency ()
  "Alterna el fondo entre translúcido y opaco en el frame actual."
  (interactive)
  (set-frame-parameter
   nil 'alpha-background
   (if (eql (frame-parameter nil 'alpha-background) 100) s1b/alpha-background 100)))

;; Un poco de aire alrededor del texto.
(add-to-list 'default-frame-alist '(internal-border-width . 12))
(setq-default line-spacing 0.12)


;;; Editor: como en nvim

(setq display-line-numbers-type 'relative
      scroll-margin 8              ; como scrolloff=8
      scroll-conservatively 101
      evil-want-fine-undo t
      evil-split-window-below t
      evil-vsplit-window-right t
      which-key-idle-delay 0.3)

(defun s1b/line-diagnostics ()
  "Muestra los diagnósticos de la línea actual (como `vim.diagnostic.open_float')."
  (interactive)
  (require 'flymake)
  (if-let* ((diags (flymake-diagnostics (line-beginning-position) (line-end-position))))
      (message "%s" (mapconcat #'flymake-diagnostic-text diags "\n"))
    (message "Sin diagnósticos en esta línea")))

(map! :n "C-h" #'evil-window-left
      :n "C-j" #'evil-window-down
      :n "C-k" #'evil-window-up
      :n "C-l" #'evil-window-right
      :n "H"   #'previous-buffer
      :n "L"   #'next-buffer
      (:leader
       :desc "Line diagnostics"     "e"   #'s1b/line-diagnostics
       :desc "Delete buffer"        "b d" #'kill-current-buffer
       :desc "Transparency"         "t o" #'s1b/toggle-transparency))

(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)


;;; doom-modeline

(after! doom-modeline
  (setq doom-modeline-height 28
        doom-modeline-bar-width 4
        doom-modeline-icon t
        doom-modeline-major-mode-icon t
        doom-modeline-major-mode-color-icon t
        doom-modeline-modal-icon t
        doom-modeline-buffer-state-icon t
        doom-modeline-buffer-file-name-style 'truncate-upto-project
        doom-modeline-buffer-encoding nil
        doom-modeline-minor-modes nil
        doom-modeline-indent-info nil
        doom-modeline-vcs-max-length 24
        doom-modeline-time-icon t))


;;; Dashboard

(defconst s1b/banner
  '("███████╗ ██╗██████╗ "
    "██╔════╝███║██╔══██╗"
    "███████╗╚██║██████╔╝"
    "╚════██║ ██║██╔══██╗"
    "███████║ ██║██████╔╝"
    "╚══════╝ ╚═╝╚═════╝ "))

(defconst s1b/greeting "hi LiveY · mango @ nixos")

(defun s1b/hex->rgb (hex)
  (mapcar (lambda (i) (string-to-number (substring hex i (+ i 2)) 16)) '(1 3 5)))

(defun s1b/blend (c1 c2 alpha)
  "Mezcla los colores hex C1 y C2 (ALPHA = peso de C1)."
  (apply #'format "#%02x%02x%02x"
         (cl-mapcar (lambda (a b) (round (+ (* a alpha) (* b (- 1 alpha)))))
                    (s1b/hex->rgb c1) (s1b/hex->rgb c2))))

(defun s1b/center (line width)
  (concat (make-string (max 0 (/ (- width (string-width line)) 2)) ?\s) line))

(defun s1b/dashboard-banner ()
  "Banner S1B con degradado rosa → morado y saludo."
  (let* ((width (apply #'max (string-width s1b/greeting)
                       (mapcar #'string-width s1b/banner)))
         (n (1- (length s1b/banner)))
         (i -1))
    (concat
     (mapconcat
      (lambda (line)
        (setq i (1+ i))
        (propertize (s1b/center line width)
                    'face `(:foreground ,(s1b/blend (s1b/color 'base0D) (s1b/color 'base0E)
                                                    (/ (float i) (max n 1)))
                            :weight bold)))
      s1b/banner "\n")
     "\n\n"
     (propertize (s1b/center s1b/greeting width)
                 'face `(:foreground ,(s1b/color 'base04) :slant italic)))))

(setq fancy-splash-image nil
      +dashboard-ascii-banner-fn #'s1b/dashboard-banner
      +dashboard-functions '(+dashboard-widget-banner
                             +dashboard-widget-shortmenu
                             +dashboard-widget-loaded))


;;; Completado: vertico flotante + consult + marginalia

(after! vertico-posframe
  (setq vertico-posframe-poshandler #'posframe-poshandler-frame-center
        vertico-posframe-border-width 2
        vertico-posframe-width 100
        vertico-posframe-parameters '((left-fringe . 10)
                                      (right-fringe . 10)
                                      (alpha-background . 96))))

(after! vertico
  (setq vertico-count 14
        vertico-cycle t))

(after! consult
  ;; Vista previa automática con un pequeño retraso (archivos, ripgrep, temas).
  (setq consult-preview-key '(:debounce 0.25 any)
        consult-narrow-key "<"))

(after! marginalia
  (setq marginalia-align 'right))


;;; dirvish: navegación con hjkl

(after! dirvish
  (setq dirvish-attributes '(nerd-icons subtree-state vc-state file-size file-time)
        dirvish-use-header-line 'global
        dirvish-header-line-format '(:left (path) :right (free-space))
        dirvish-mode-line-format '(:left (sort symlink) :right (omit yank index))
        dirvish-subtree-state-style 'nerd
        delete-by-moving-to-trash t)
  (map! :map dirvish-mode-map
        :n "h"   #'dired-up-directory
        :n "l"   #'dired-find-file
        :n "TAB" #'dirvish-subtree-toggle
        :n "s"   #'dirvish-quicksort
        :n "M-p" #'dirvish-layout-toggle))


;;; Detalles de código

(after! hl-todo
  (setq hl-todo-keyword-faces
        `(("TODO"   . ,(s1b/color 'base0E))
          ("FIXME"  . ,(s1b/color 'base08))
          ("BUG"    . ,(s1b/color 'base08))
          ("HACK"   . ,(s1b/color 'base09))
          ("REVIEW" . ,(s1b/color 'base0A))
          ("NOTE"   . ,(s1b/color 'base0C))
          ("DEPRECATED" . ,(s1b/color 'base03)))))

(after! indent-bars
  (setq indent-bars-color '(highlight :face-bg t :blend 0.12)
        indent-bars-width-frac 0.15
        indent-bars-highlight-current-depth '(:blend 0.4)))

(after! nav-flash
  (setq nav-flash-delay 0.25))


;;; org: org-modern + mixed-pitch

(setq org-directory "~/org/")

(after! org
  (setq org-hide-emphasis-markers t
        org-pretty-entities t
        org-ellipsis " ▾"
        org-startup-indented t
        org-auto-align-tags nil
        org-tags-column 0
        org-fontify-quote-and-verse-blocks t))

(after! org-modern
  (setq org-modern-star 'replace
        org-modern-replace-stars "◉○◈◇✳"
        org-modern-table-vertical 1
        org-modern-block-name '("‹" . "›")))

(add-hook 'org-mode-hook #'mixed-pitch-mode)
(after! mixed-pitch
  (setq mixed-pitch-set-height t))
