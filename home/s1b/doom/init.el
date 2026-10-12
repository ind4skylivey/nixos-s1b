;;; init.el -*- lexical-binding: t; -*-
;; Módulos de Doom (versión fijada en home/s1b/emacs.nix → doomRev).
;; Tras cambiar este archivo o packages.el: `doom sync` y reiniciar Emacs.

;; VM con 2 vCPU: la compilación nativa diferida, de a un trabajo.
(setq native-comp-async-jobs-number 1)

(doom! :input

       :completion
       (corfu +orderless +icons)   ; autocompletado en el buffer
       (vertico +icons +childframe) ; minibuffer flotante + consult/marginalia

       :ui
       doom                ; doom-themes + solaire
       dashboard           ; pantalla de inicio (banner S1B)
       hl-todo             ; TODO/FIXME/NOTE en color
       indent-guides       ; guías de indentación discretas
       ligatures           ; ligaduras de Maple Mono
       modeline            ; doom-modeline
       nav-flash           ; destello en la línea tras saltar
       ophints             ; resalta lo que opera un verbo (y, d, c…)
       (popup +defaults)   ; popups ordenados
       (smooth-scroll +interpolate) ; scroll suave (también C-d/C-u)
       (vc-gutter +pretty) ; diff de git en el margen
       vi-tilde-fringe     ; ~ tras el final del buffer, como vim
       workspaces          ; espacios de trabajo por proyecto

       :editor
       (evil +everywhere)  ; vim en todas partes
       file-templates
       fold
       snippets
       (whitespace +guess +trim)

       :emacs
       (dired +dirvish +icons) ; dirvish con iconos
       electric
       (ibuffer +icons)
       undo
       vc

       :term
       vterm               ; vterm viene precompilado de nixpkgs

       :checkers
       (syntax +flymake +icons)

       :tools
       direnv
       (eval +overlay)
       lookup
       magit
       tree-sitter         ; gramáticas precompiladas de nixpkgs

       :os

       :lang
       emacs-lisp
       (json +tree-sitter)
       (lua +tree-sitter)
       (markdown +tree-sitter)
       (nix +tree-sitter)
       (org +pretty)       ; org-modern
       (php +tree-sitter)
       (python +tree-sitter)
       (rust +tree-sitter)
       sh
       (yaml +tree-sitter)

       :email

       :app

       :config
       (default +bindings +smartparens))
