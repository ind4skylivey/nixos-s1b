-- Punto de entrada: la paleta (vim.g.s1b_palette) y la ruta del flake
-- (vim.g.s1b_flake) llegan desde el init.lua que genera Nix.
require("s1b.options")
require("s1b.colors")
require("s1b.keymaps")
require("s1b.editor")
require("s1b.ui")
require("s1b.git")
require("s1b.completion")
require("s1b.lsp")
