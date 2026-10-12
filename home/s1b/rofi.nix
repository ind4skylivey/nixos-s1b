# Rofi "Neon S1B Hk": lanzador (Super+D), run y ventanas (Super+Alt+W).
{
  config,
  pkgs,
  ...
}:
let
  c = config.lib.stylix.colors.withHashtag;
  monoFont = config.stylix.fonts.monospace.name;
  sansFont = config.stylix.fonts.sansSerif.name;

  theme = pkgs.writeText "neon-s1b-hk.rasi" ''
    * {
        bg:        ${c.base00}eb;
        bg-solid:  ${c.base00};
        surface:   ${c.base01};
        overlay:   ${c.base02};
        muted:     ${c.base03};
        subtle:    ${c.base04};
        fg:        ${c.base05};
        accent:    ${c.base0D};
        magenta:   ${c.base0E};
        red:       ${c.base08};

        font:             "${sansFont} 12";
        background-color: transparent;
        text-color:       @fg;
        margin:  0;
        padding: 0;
        spacing: 0;
    }

    window {
        location:         center;
        width:            600px;
        border:           1px;
        border-color:     ${c.base0D}66;
        border-radius:    18px;
        background-color: @bg;
        padding:          18px;
    }

    mainbox {
        spacing:  14px;
        children: [ inputbar, message, listview, mode-switcher ];
    }

    inputbar {
        background-color: @surface;
        border:           1px;
        border-color:     ${c.base0D}33;
        border-radius:    12px;
        padding:          10px 14px;
        spacing:          12px;
        children:         [ prompt, entry ];
    }
    prompt {
        text-color: @accent;
        font:       "${monoFont} 14";
    }
    entry {
        placeholder:       "Search…";
        placeholder-color: @muted;
        cursor:            text;
    }

    message {
        background-color: @surface;
        border-radius:    10px;
        padding:          8px 12px;
    }
    textbox { text-color: @subtle; }

    listview {
        lines:        7;
        columns:      1;
        fixed-height: true;
        scrollbar:    false;
        spacing:      4px;
        cycle:        true;
    }

    element {
        padding:       8px 12px;
        spacing:       12px;
        border-radius: 10px;
    }
    element normal.normal,
    element alternate.normal { background-color: transparent; text-color: @fg; }
    element normal.urgent,
    element alternate.urgent { text-color: @red; }
    element normal.active,
    element alternate.active { text-color: @accent; }
    element selected.normal {
        background-image: linear-gradient(to right, ${c.base0D}40, ${c.base0E}26);
        border:           0 0 0 3px;
        border-color:     @accent;
        text-color:       ${c.base07};
    }
    element selected.urgent { background-color: ${c.base08}40; text-color: ${c.base07}; }
    element selected.active { background-color: ${c.base0D}55; text-color: ${c.base07}; }

    element-icon {
        size:             24px;
        background-color: transparent;
        text-color:       inherit;
    }
    element-text {
        background-color: transparent;
        text-color:       inherit;
        vertical-align:   0.5;
    }

    mode-switcher { spacing: 8px; }
    button {
        padding:          6px;
        border-radius:    10px;
        background-color: @surface;
        text-color:       @muted;
        font:             "${monoFont} 12";
    }
    button selected {
        background-color: ${c.base0D}33;
        text-color:       @accent;
    }
  '';
in
{
  programs.rofi = {
    enable = true;
    terminal = "kitty";
    theme = "${theme}";
    extraConfig = {
      modes = "drun,run,window";
      show-icons = true;
      icon-theme = "Papirus-Dark";
      drun-display-format = "{name}";
      disable-history = false;
      display-drun = "󰀻";
      display-run = "";
      display-window = "󱂬";
      window-format = "{c}  ·  {t}";
      kb-cancel = "Escape,MouseSecondary";
      kb-accept-entry = "Control+j,Control+m,Return,KP_Enter,MouseMiddle";
      kb-row-select = "";
      kb-mode-next = "Shift+Right,Control+Tab,Control+space";
      kb-mode-previous = "Shift+Left,Control+ISO_Left_Tab,Control+Shift+space";
      kb-row-up = "Up,Control+p,Control+z";
      kb-row-down = "Down,Control+n,Control+x";
    };
  };
}
