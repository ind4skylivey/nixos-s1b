-- LSP nativo (vim.lsp.config / vim.lsp.enable). nvim-lspconfig solo aporta
-- los valores por defecto de cada servidor; los binarios vienen de Nix.
local map = vim.keymap.set
local tb = require("telescope.builtin")
local flake = vim.g.s1b_flake

-- ------------------------------------------------------------ diagnósticos
local sev = vim.diagnostic.severity
vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = false,
  virtual_text = { spacing = 2, prefix = "●" },
  float = { source = "if_many" },
  signs = { text = { [sev.ERROR] = "", [sev.WARN] = "", [sev.INFO] = "", [sev.HINT] = "󰌵" } },
})

local caps = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then caps = cmp_lsp.default_capabilities(caps) end
vim.lsp.config("*", { capabilities = caps })

-- ------------------------------------------------------------ servidores
vim.lsp.config("nixd", {
  cmd = { "nixd" },
  filetypes = { "nix" },
  root_markers = { "flake.nix", "flake.lock", ".git" },
  settings = {
    nixd = {
      formatting = { command = { "nixfmt" } },
      nixpkgs = { expr = 'import (builtins.getFlake "' .. flake .. '").inputs.nixpkgs { }' },
      options = {
        nixos = {
          expr = '(builtins.getFlake "' .. flake .. '").nixosConfigurations.nixos.options',
        },
        home_manager = {
          expr = '(builtins.getFlake "' .. flake .. '").nixosConfigurations.nixos.options.home-manager.users.type.getSubOptions []',
        },
      },
    },
  },
})

vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
      telemetry = { enable = false },
    },
  },
})

-- shellcheck (diagnósticos) y shfmt (formato) los llama bash-language-server.
vim.lsp.config("bashls", {
  cmd = { "bash-language-server", "start" },
  filetypes = { "bash", "sh" },
  root_markers = { ".git" },
  settings = {
    bashIde = {
      globPattern = "*@(.sh|.inc|.bash|.command)",
      shellcheckPath = "shellcheck",
      shfmt = { path = "shfmt", caseIndent = true },
    },
  },
})

vim.lsp.enable({ "nixd", "lua_ls", "bashls" })

-- Formato al guardar solo donde el formateador es canónico.
local format_on_save = { nix = true, sh = true, bash = true }

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("s1b_lsp", { clear = true }),
  callback = function(ev)
    local buf = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local function bmap(lhs, rhs, desc) map("n", lhs, rhs, { buffer = buf, desc = desc }) end
    bmap("gd", tb.lsp_definitions, "Definition")
    bmap("grr", tb.lsp_references, "References")
    bmap("gri", tb.lsp_implementations, "Implementations")
    bmap("K", vim.lsp.buf.hover, "Hover")
    bmap("<leader>rn", vim.lsp.buf.rename, "Rename")
    bmap("<leader>ca", vim.lsp.buf.code_action, "Code action")
    bmap("<leader>cs", tb.lsp_document_symbols, "Document symbols")
    if not client then return end

    -- Resalta el símbolo bajo el cursor y sus referencias.
    if client:supports_method("textDocument/documentHighlight", buf) then
      local g = vim.api.nvim_create_augroup("s1b_lsp_hl_" .. buf, { clear = false })
      vim.api.nvim_clear_autocmds({ group = g, buffer = buf })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = buf, group = g, callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
        buffer = buf, group = g, callback = vim.lsp.buf.clear_references,
      })
    end

    if format_on_save[vim.bo[buf].filetype] and client:supports_method("textDocument/formatting", buf) then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = buf,
        group = vim.api.nvim_create_augroup("s1b_lsp_fmt_" .. buf, { clear = true }),
        callback = function()
          vim.lsp.buf.format({ async = false, timeout_ms = 4000, bufnr = buf, id = client.id })
        end,
      })
    end
  end,
})
