# Apps de terminal tematizadas: btop, yazi, neovim (ligero).
{ config, pkgs, ... }:
let
  c = config.lib.stylix.colors;
in
{
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "neon-s1b-hk";
      theme_background = false;
      truecolor = true;
      rounded_corners = true;
      update_ms = 1000;
      proc_sorting = "cpu lazy";
    };
  };

  # Colores btop vía archivo de tema propio (TTY no usa stylix).
  xdg.configFile."btop/themes/neon-s1b-hk.theme".text = ''
    theme[main_bg]="#${c.base00}"
    theme[main_fg]="#${c.base05}"
    theme[title]="#${c.base0D}"
    theme[hi_fg]="#${c.base0E}"
    theme[selected_bg]="#${c.base02}"
    theme[selected_fg]="#${c.base07}"
    theme[inactive_fg]="#${c.base03}"
    theme[proc_misc]="#${c.base0C}"
    theme[cpu_box]="#${c.base0D}"
    theme[mem_box]="#${c.base0E}"
    theme[net_box]="#${c.base0C}"
    theme[proc_box]="#${c.base08}"
    theme[div_line]="#${c.base02}"
    theme[temp_start]="#${c.base0B}"
    theme[temp_mid]="#${c.base0A}"
    theme[temp_end]="#${c.base08}"
    theme[cpu_start]="#${c.base0D}"
    theme[cpu_mid]="#${c.base0E}"
    theme[cpu_end]="#${c.base08}"
    theme[free_start]="#${c.base0B}"
    theme[free_mid]="#${c.base0C}"
    theme[free_end]="#${c.base0D}"
    theme[cached_start]="#${c.base0A}"
    theme[cached_mid]="#${c.base09}"
    theme[cached_end]="#${c.base08}"
    theme[available_start]="#${c.base0B}"
    theme[available_mid]="#${c.base0C}"
    theme[available_end]="#${c.base0D}"
    theme[used_start]="#${c.base0E}"
    theme[used_mid]="#${c.base08}"
    theme[used_end]="#${c.base0F}"
    theme[download_start]="#${c.base0C}"
    theme[download_mid]="#${c.base0D}"
    theme[download_end]="#${c.base0E}"
    theme[upload_start]="#${c.base0A}"
    theme[upload_mid]="#${c.base09}"
    theme[upload_end]="#${c.base08}"
  '';

  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      manager = {
        show_hidden = false;
        sort_by = "alphabetical";
        sort_dir_first = true;
        ratio = [
          1
          3
          3
        ];
      };
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = false;
    withPython3 = false;
    withRuby = false;
    plugins = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
      lualine-nvim
      telescope-nvim
      plenary-nvim
      nvim-web-devicons
      base16-nvim
      nvim-lspconfig
      cmp-nvim-lsp
      nvim-cmp
    ];
    initLua = ''
      -- Fondo explícito: evita E1568 (consulta DSR al terminal).
      vim.o.background = "dark"
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.termguicolors = true
      vim.opt.signcolumn = "yes"
      vim.opt.cursorline = true
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.g.mapleader = " "

      require("base16-colorscheme").setup({
        base00 = "#${c.base00}", base01 = "#${c.base01}", base02 = "#${c.base02}", base03 = "#${c.base03}",
        base04 = "#${c.base04}", base05 = "#${c.base05}", base06 = "#${c.base06}", base07 = "#${c.base07}",
        base08 = "#${c.base08}", base09 = "#${c.base09}", base0A = "#${c.base0A}", base0B = "#${c.base0B}",
        base0C = "#${c.base0C}", base0D = "#${c.base0D}", base0E = "#${c.base0E}", base0F = "#${c.base0F}",
      })

      require("lualine").setup({
        options = {
          theme = "base16",
          section_separators = { left = "", right = "" },
          component_separators = { left = "│", right = "│" },
        },
      })

      -- nvim-treesitter (rama main): ya no existe nvim-treesitter.configs.
      -- Las gramáticas vienen de withAllGrammars; se activan por FileType.
      require("nvim-treesitter").setup({})
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      local telescope = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", telescope.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", telescope.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", telescope.buffers, { desc = "Buffers" })

      -- Nix LSP via native vim.lsp.config (avoids nvim-0.11 deprecation)
      local caps = vim.lsp.protocol.make_client_capabilities()
      local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok_cmp then
        caps = cmp_lsp.default_capabilities(caps)
      end
      local flake_path = vim.fn.expand("~") .. "/nixos-mango"
      vim.lsp.config("nixd", {
        cmd = { "nixd" },
        filetypes = { "nix" },
        root_markers = { "flake.nix", "flake.lock", ".git" },
        capabilities = caps,
        settings = {
          nixd = {
            formatting = { command = { "nixfmt" } },
            nixpkgs = { expr = 'import (builtins.getFlake "' .. flake_path .. '").inputs.nixpkgs { }' },
            options = {
              nixos = {
                expr = '(builtins.getFlake "' .. flake_path .. '").nixosConfigurations.nixos.options',
              },
              home_manager = {
                expr = '(builtins.getFlake "'
                  .. flake_path
                  .. '").nixosConfigurations.nixos.options.home-manager.users.type.getSubOptions []',
              },
            },
          },
        },
      })
      vim.lsp.enable("nixd")

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("mango_lsp", { clear = true }),
        callback = function(ev)
          local buf = ev.buf
          local opts = { buffer = buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          if vim.bo[buf].filetype == "nix" then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = buf,
              group = vim.api.nvim_create_augroup("mango_lsp_fmt_" .. buf, { clear = true }),
              callback = function()
                vim.lsp.buf.format({ async = false, timeout_ms = 4000, bufnr = buf })
              end,
            })
          end
        end,
      })

      local ok_cmp2, cmp = pcall(require, "cmp")
      if ok_cmp2 then
        cmp.setup({
          mapping = cmp.mapping.preset.insert({
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<CR>"] = cmp.mapping.confirm({ select = false }),
            ["<Tab>"] = cmp.mapping.select_next_item(),
            ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          }),
          sources = { { name = "nvim_lsp" } },
        })
      end
    '';
  };

  # stylix ya tematiza neovim si el target está activo; lo dejamos a nuestro
  # colorscheme base16 para no pelearse con la config lua.
  stylix.targets.neovim.enable = false;
  stylix.targets.btop.enable = false;
  stylix.targets.yazi.enable = true;
}
