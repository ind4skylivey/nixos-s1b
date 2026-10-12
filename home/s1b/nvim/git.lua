local map = vim.keymap.set

require("gitsigns").setup({
  signs = {
    add = { text = "▎" },
    change = { text = "▎" },
    delete = { text = "▁" },
    topdelete = { text = "▔" },
    changedelete = { text = "▎" },
    untracked = { text = "┆" },
  },
  on_attach = function(buf)
    local gs = require("gitsigns")
    local function bmap(lhs, rhs, desc) map("n", lhs, rhs, { buffer = buf, desc = desc }) end
    bmap("]h", function() gs.nav_hunk("next") end, "Next hunk")
    bmap("[h", function() gs.nav_hunk("prev") end, "Prev hunk")
    bmap("<leader>hs", gs.stage_hunk, "Stage hunk")
    bmap("<leader>hr", gs.reset_hunk, "Reset hunk")
    bmap("<leader>hp", gs.preview_hunk_inline, "Preview hunk")
    bmap("<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
    bmap("<leader>hB", gs.toggle_current_line_blame, "Toggle line blame")
  end,
})

map("n", "<leader>gd", "<cmd>DiffviewOpen<CR>", { desc = "Diff view" })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", { desc = "File history" })
map("n", "<leader>gH", "<cmd>DiffviewFileHistory<CR>", { desc = "Repo history" })
map("n", "<leader>gq", "<cmd>DiffviewClose<CR>", { desc = "Close diff view" })

-- lazygit en una pestaña propia; se cierra sola al salir.
map("n", "<leader>gg", function()
  vim.cmd.tabnew()
  local tab, buf = vim.api.nvim_get_current_tabpage(), vim.api.nvim_get_current_buf()
  vim.fn.jobstart({ "lazygit" }, {
    term = true,
    on_exit = function()
      vim.schedule(function()
        if vim.api.nvim_tabpage_is_valid(tab) and #vim.api.nvim_list_tabpages() > 1 then
          vim.cmd.tabclose(vim.api.nvim_tabpage_get_number(tab))
        end
        if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
      end)
    end,
  })
  vim.cmd.startinsert()
end, { desc = "Lazygit" })
