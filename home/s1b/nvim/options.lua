-- Fondo explícito: evita E1568 (consulta DSR al terminal).
vim.o.background = "dark"
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local o = vim.opt
o.number = true
o.relativenumber = true
o.termguicolors = true
o.signcolumn = "yes"
o.cursorline = true
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.ignorecase = true
o.smartcase = true
o.scrolloff = 7
o.sidescrolloff = 8
o.undofile = true
o.swapfile = false
o.clipboard = "unnamedplus" -- wl-clipboard viene en el wrapper
o.updatetime = 250
o.timeoutlen = 400
o.splitright = true
o.splitbelow = true
o.laststatus = 3
o.showmode = false
o.inccommand = "split"
o.winborder = "rounded"
o.list = true
o.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
