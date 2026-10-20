# Neovim ligero: plugins de nixpkgs (caché binario), Lua en ./nvim/ y solo
# la paleta de stylix + la ruta del flake se generan desde Nix.
{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:
let
  c = config.lib.stylix.colors;
  bases = [
    "base00"
    "base01"
    "base02"
    "base03"
    "base04"
    "base05"
    "base06"
    "base07"
    "base08"
    "base09"
    "base0A"
    "base0B"
    "base0C"
    "base0D"
    "base0E"
    "base0F"
  ];
  palette = lib.concatMapStringsSep "\n" (b: ''${b} = "#${c.${b}}",'') bases;
in
{
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
      base16-nvim
      lualine-nvim
      nvim-web-devicons
      which-key-nvim
      mini-hipatterns
      plenary-nvim
      telescope-nvim
      telescope-fzf-native-nvim
      flash-nvim
      gitsigns-nvim
      diffview-nvim
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
    ];

    # Solo en el PATH de nvim (nixd y nixfmt ya vienen del sistema).
    extraPackages = with pkgs; [
      lua-language-server
      bash-language-server
      shellcheck
      shfmt
      tree-sitter # CLI (lo pide :checkhealth nvim-treesitter)
    ];

    initLua = ''
      vim.g.s1b_palette = {
      ${palette}
      }
      vim.g.s1b_flake = "${osConfig.s1b.flakeCheckout}"
      require("s1b")
    '';
  };

  xdg.configFile."nvim/lua/s1b".source = ./nvim;

  # Colores propios vía base16-nvim (ver nvim/colors.lua).
  stylix.targets.neovim.enable = false;
}
