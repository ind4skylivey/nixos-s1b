-- base16 con la paleta de stylix + fondo transparente (kitty ya tiene opacidad).
local p = vim.g.s1b_palette
local transparent = true

local clear_bg = {
  "Normal", "NormalNC", "SignColumn", "LineNr", "CursorLineNr", "FoldColumn", "EndOfBuffer",
  "GitSignsAdd", "GitSignsChange", "GitSignsDelete", "GitSignsTopdelete", "GitSignsChangedelete",
  "GitSignsUntracked", "DiagnosticSignError", "DiagnosticSignWarn", "DiagnosticSignInfo", "DiagnosticSignHint",
}

local function apply()
  require("base16-colorscheme").setup(p)
  if transparent then
    for _, name in ipairs(clear_bg) do
      local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
      hl.bg, hl.ctermbg = nil, nil
      vim.api.nvim_set_hl(0, name, hl)
    end
  end
  -- Acentos neón: número de línea actual en morado, búsqueda en rojo.
  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = p.base0D, bold = true })
  vim.api.nvim_set_hl(0, "CurSearch", { fg = p.base00, bg = p.base08, bold = true })
end

apply()

vim.keymap.set("n", "<leader>ut", function()
  transparent = not transparent
  apply()
end, { desc = "Toggle transparency" })
