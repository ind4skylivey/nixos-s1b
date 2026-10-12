-- ------------------------------------------------------------ statusline
require("lualine").setup({
  options = {
    theme = "base16",
    globalstatus = true,
    section_separators = { left = "", right = "" },
    component_separators = { left = "│", right = "│" },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = {
      { "b:gitsigns_head", icon = "" },
      {
        "diff",
        source = function()
          local g = vim.b.gitsigns_status_dict
          if g then return { added = g.added, modified = g.changed, removed = g.removed } end
        end,
      },
    },
    lualine_c = { { "filename", path = 1 } },
    lualine_x = {
      { "diagnostics", symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " } },
      "filetype",
    },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
  tabline = {
    lualine_a = { { "buffers", symbols = { modified = " ●", alternate_file = "" } } },
    lualine_z = { "tabs" },
  },
})

-- ------------------------------------------------------------ hipatterns
-- Colores hex en vivo (#rrggbb y base0X = "rrggbb" de schemes.nix) + TODO/FIXME.
local hp = require("mini.hipatterns")
hp.setup({
  highlighters = {
    fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
    hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
    todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
    note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
    hex_color = hp.gen_highlighter.hex_color(),
    base16 = {
      pattern = 'base0%x = "()%x%x%x%x%x%x()"',
      group = function(_, match) return hp.compute_hex_color_group("#" .. match, "bg") end,
    },
  },
})

-- ------------------------------------------------------------ which-key
require("which-key").setup({
  preset = "helix",
  delay = 300,
  spec = {
    { "<leader>b", group = "buffer" },
    { "<leader>c", group = "code" },
    { "<leader>f", group = "find" },
    { "<leader>g", group = "git" },
    { "<leader>h", group = "hunks" },
    { "<leader>u", group = "ui" },
  },
})
