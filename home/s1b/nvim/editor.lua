local map = vim.keymap.set

-- nvim-treesitter (rama main): ya no existe nvim-treesitter.configs.
-- Las gramáticas vienen de withAllGrammars; se activan por FileType.
require("nvim-treesitter").setup({})
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("s1b_treesitter", { clear = true }),
  callback = function(args)
    if pcall(vim.treesitter.start, args.buf) then
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

-- ------------------------------------------------------------ telescope
local telescope = require("telescope")
local actions = require("telescope.actions")
telescope.setup({
  defaults = {
    prompt_prefix = "  ",
    selection_caret = "▍ ",
    sorting_strategy = "ascending",
    layout_config = { prompt_position = "top" },
    file_ignore_patterns = { "%.git/" },
    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
      },
    },
  },
  pickers = { find_files = { hidden = true } },
})
pcall(telescope.load_extension, "fzf")

local tb = require("telescope.builtin")
map("n", "<leader>ff", tb.find_files, { desc = "Find files" })
map("n", "<leader>fg", tb.live_grep, { desc = "Live grep" })
map("n", "<leader>fb", tb.buffers, { desc = "Buffers" })
map("n", "<leader>fh", tb.help_tags, { desc = "Help" })
map("n", "<leader>fo", tb.oldfiles, { desc = "Recent files" })
map("n", "<leader>fr", tb.resume, { desc = "Resume picker" })
map("n", "<leader>fw", tb.grep_string, { desc = "Grep word" })
map("n", "<leader>fd", tb.diagnostics, { desc = "Diagnostics" })
map("n", "<leader>fk", tb.keymaps, { desc = "Keymaps" })
map("n", "<leader>ft", function()
  tb.grep_string({ search = [[\b(TODO|FIXME|HACK|NOTE|XXX)\b]], use_regex = true, prompt_title = "TODOs" })
end, { desc = "TODOs" })
map("n", "<leader>/", function()
  tb.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({ previewer = false }))
end, { desc = "Fuzzy in buffer" })

-- ------------------------------------------------------------ movimiento
local flash = require("flash")
flash.setup({})
map({ "n", "x", "o" }, "s", flash.jump, { desc = "Flash" })
map({ "n", "x", "o" }, "S", flash.treesitter, { desc = "Flash treesitter" })
map("o", "r", flash.remote, { desc = "Remote flash" })
