local map = vim.keymap.set
local aug = function(name) return vim.api.nvim_create_augroup("s1b_" .. name, { clear = true }) end

map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "H", "<cmd>bprevious<CR>", { desc = "Prev buffer" })
map("n", "L", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics" })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = aug("yank"),
  callback = function() vim.hl.on_yank({ timeout = 150 }) end,
})

-- Volver a la última posición al reabrir un archivo.
vim.api.nvim_create_autocmd("BufReadPost", {
  group = aug("lastpos"),
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
