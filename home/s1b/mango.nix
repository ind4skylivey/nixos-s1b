# mango (HM): derivado de hakuspace src/home/.config/mango/*.conf, adaptado a
# las claves de mango 0.18.0 (assets/config.conf) y a una VM ligera.
# El módulo HM valida el archivo con `mango -c <archivo> -p` al construir.
{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  c = config.lib.stylix.colors; # hex sin '#', p. ej. "b06cff"
  rgba = hex: alpha: "0x${hex}${alpha}";

  xkb = osConfig.services.xserver.xkb;
  # Variante/opciones xkb solo si el instalador las definió.
  xkbExtra =
    lib.optionalAttrs (xkb.variant != "") { xkb_rules_variant = xkb.variant; }
    // lib.optionalAttrs (xkb.options != "") { xkb_rules_options = xkb.options; };

  term = "kitty";
  launcher = "rofi -show drun";

  tags = lib.range 1 9;

  wlogoutCmd = "power-menu"; # ver wlogout.nix
  volUp = "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
  volDown = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
  volMute = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
  micMute = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

  # Cada atajo: k = "MODS,tecla", a = "acción[,args]", d = descripción
  # para la chuleta (null = no se lista; los rangos de tags se resumen).
  # Todas las acciones verificadas contra src/config/binding_parse.c (0.18.0).
  b = k: a: d: { inherit k a d; };
  binds = [
    # ── sesión
    (b "SUPER,Escape" "spawn,hyprlock" "Lock screen")
    (b "SUPER+SHIFT,e" "spawn,${wlogoutCmd}" "Power menu (wlogout)")
    (b "SUPER+SHIFT,q" "spawn,${wlogoutCmd}" "Power menu (wlogout)")
    (b "SUPER+CTRL,r" "reload_config" "Reload mango config")
    (b "SUPER+SHIFT,r" "reload_config" null)
    (b "SUPER+SHIFT,w" "spawn_shell,systemctl --user restart waybar" "Restart waybar")
    (b "SUPER,slash" "spawn,mango-keybinds" "This cheatsheet")
    (b "SUPER,F1" "spawn,mango-keybinds" "This cheatsheet")

    # ── apps
    (b "SUPER,Return" "spawn,${term}" "Terminal (kitty)")
    (b "SUPER+SHIFT,Return" "spawn,${term} --class kitty-float" "Floating terminal")
    (b "SUPER,grave" "toggle_named_scratchpad,kitty-scratch,none,${term} --class kitty-scratch"
      "Scratchpad terminal"
    )
    (b "SUPER,b" "spawn,helium" "Browser (Helium)")
    (b "SUPER+ALT,e" "spawn,strata" "File manager (Strata)")
    (b "SUPER,y" "spawn,${term} --class kitty-yazi -e yazi" "yazi (TUI files)")
    (b "SUPER,m" "spawn,${term} --class kitty-btop -e btop" "btop (monitor)")
    (b "SUPER+ALT,n" "spawn,${term} --class kitty-nvim -e nvim" "Neovim")
    (b "SUPER+ALT,p" "spawn,${term} --class kitty-ns -e ns" "nix-search-tv (ns)")

    # ── menús
    (b "SUPER,d" "spawn,${launcher}" "App launcher")
    (b "SUPER+SHIFT,d" "spawn,rofi -show run" "Run command")
    (b "SUPER+ALT,w" "spawn,rofi -show window" "Window list")
    (b "SUPER,v" "spawn,mango-clipboard" "Clipboard history")
    (b "SUPER,semicolon"
      "spawn,rofimoji --selector rofi --action copy --clipboarder wl-copy --skin-tone neutral"
      "Emoji picker (copies)"
    )
    (b "SUPER,c" "spawn,rofi -show calc -modi calc -no-show-match -no-sort" "Calculator")
    (b "SUPER+CTRL,w" "spawn,${term} --class kitty-nmtui -e nmtui" "Wi-Fi / network (nmtui)")
    (b "SUPER,n" "spawn,swaync-client -t -sw" "Notification center")
    (b "SUPER+SHIFT,n" "spawn,swaync-client -d -sw" "Do not disturb")
    (b "SUPER,w" "spawn,mango-wallpaper-next" "Next wallpaper")
    (b "SUPER,t" "spawn,mango-theme-switch" "Switch theme")

    # ── capturas (75 %: sin Print; los binds Print siguen por si acaso)
    (b "SUPER+SHIFT,s" ''spawn_shell,grim -g "$(slurp)" - | wl-copy'' "Screenshot region → clipboard")
    (b "SUPER+SHIFT,a" "spawn,mango-screenshot region" "Screenshot region → satty")
    (b "SUPER+CTRL,s" "spawn,mango-screenshot full" "Screenshot full → file + clipboard")
    (b "NONE,Print" "spawn,mango-screenshot region" null)
    (b "SHIFT,Print" "spawn,mango-screenshot full" null)

    # ── ventanas
    (b "SUPER,q" "killclient," "Close window")
    (b "SUPER+SHIFT,space" "togglefloating," "Toggle floating")
    (b "SUPER,f" "togglefullscreen," "Fullscreen")
    (b "SUPER+SHIFT,f" "togglemaximizescreen," "Maximize")
    (b "ALT+SHIFT,f" "togglefakefullscreen," "Fake fullscreen")
    (b "SUPER+ALT,c" "centerwin," "Center floating window")
    (b "SUPER,g" "toggleglobal," "Sticky on all tags")
    (b "SUPER,x" "toggleoverlay," "Always on top")
    (b "SUPER,i" "minimized," "Minimize")
    (b "SUPER+SHIFT,i" "restore_minimized" "Restore minimized")
    (b "SUPER+SHIFT,grave" "toggle_scratchpad" "Show/hide minimized (scratchpad)")
    (b "SUPER+CTRL,Return" "zoom," "Swap with master")

    # ── foco
    (b "SUPER,h" "focusdir,left" "Focus left (also ←)")
    (b "SUPER,j" "focusdir,down" "Focus down (also ↓)")
    (b "SUPER,k" "focusdir,up" "Focus up (also ↑)")
    (b "SUPER,l" "focusdir,right" "Focus right (also →)")
    (b "SUPER,Left" "focusdir,left" null)
    (b "SUPER,Down" "focusdir,down" null)
    (b "SUPER,Up" "focusdir,up" null)
    (b "SUPER,Right" "focusdir,right" null)
    (b "SUPER,Tab" "focusstack,next" "Next window in stack")
    (b "SUPER+SHIFT,Tab" "focusstack,prev" "Previous window in stack")
    (b "SUPER,u" "focuslast," "Last focused window")
    (b "SUPER,o" "toggleoverview," "Overview")
    (b "ALT,Tab" "toggleoverview," "Overview")
    (b "SUPER+SHIFT,o" "togglejump," "Jump to window (labels)")

    # ── mover / intercambiar
    (b "SUPER+SHIFT,h" "exchange_client,left" "Swap left (also Shift+←)")
    (b "SUPER+SHIFT,j" "exchange_client,down" "Swap down (also Shift+↓)")
    (b "SUPER+SHIFT,k" "exchange_client,up" "Swap up (also Shift+↑)")
    (b "SUPER+SHIFT,l" "exchange_client,right" "Swap right (also Shift+→)")
    (b "SUPER+SHIFT,Left" "exchange_client,left" null)
    (b "SUPER+SHIFT,Down" "exchange_client,down" null)
    (b "SUPER+SHIFT,Up" "exchange_client,up" null)
    (b "SUPER+SHIFT,Right" "exchange_client,right" null)

    # ── redimensionar
    (b "SUPER+CTRL,h" "resizewin,-50,+0" "Narrower")
    (b "SUPER+CTRL,l" "resizewin,+50,+0" "Wider")
    (b "SUPER+CTRL,k" "resizewin,+0,-50" "Shorter")
    (b "SUPER+CTRL,j" "resizewin,+0,+50" "Taller")
    (b "CTRL+ALT,Left" "resizewin,-50,+0" null)
    (b "CTRL+ALT,Right" "resizewin,+50,+0" null)
    (b "CTRL+ALT,Up" "resizewin,+0,-50" null)
    (b "CTRL+ALT,Down" "resizewin,+0,+50" null)
    (b "SUPER,minus" "setmfact,-0.05" "Master area smaller")
    (b "SUPER,equal" "setmfact,+0.05" "Master area bigger")
    (b "SUPER+SHIFT,minus" "incnmaster,-1" "Fewer masters")
    (b "SUPER+SHIFT,equal" "incnmaster,+1" "More masters")

    # ── scroller
    (b "SUPER,r" "switch_proportion_preset," "Cycle column width")
    (b "SUPER,e" "set_proportion,1.0" "Full-width column")
    (b "SUPER+CTRL,Left" "scroller_stack,left" "Stack into column left (Ctrl+arrows)")
    (b "SUPER+CTRL,Right" "scroller_stack,right" null)
    (b "SUPER+CTRL,Up" "scroller_stack,up" null)
    (b "SUPER+CTRL,Down" "scroller_stack,down" null)

    # ── distribuciones
    (b "SUPER,space" "switch_layout" "Cycle layouts")
    (b "SUPER+ALT,s" "setlayout,scroller" "Layout: scroller")
    (b "SUPER+ALT,t" "setlayout,tile" "Layout: tile")
    (b "SUPER+ALT,m" "setlayout,monocle" "Layout: monocle")
    (b "SUPER+ALT,g" "setlayout,grid" "Layout: grid")
    (b "SUPER+ALT,k" "setlayout,deck" "Layout: deck")
    (b "SUPER+ALT,d" "setlayout,dwindle" "Layout: dwindle")

    # ── gaps
    (b "SUPER+ALT,0" "togglegaps" "Toggle gaps")
    (b "SUPER+ALT,equal" "incgaps,1" "Gaps +")
    (b "SUPER+ALT,minus" "incgaps,-1" "Gaps −")

    # ── tags y monitores
    (b "SUPER,0" "view,00,0" "View all tags")
    (b "SUPER+ALT,Left" "viewtoleft_have_client,0" "Previous busy tag")
    (b "SUPER+ALT,Right" "viewtoright_have_client,0" "Next busy tag")
    (b "SUPER+SHIFT,bracketleft" "tagtoleft,0" "Move window to tag −1")
    (b "SUPER+SHIFT,bracketright" "tagtoright,0" "Move window to tag +1")
    (b "SUPER,comma" "focusmon,prev" "Focus previous monitor")
    (b "SUPER,period" "focusmon,next" "Focus next monitor")
    (b "SUPER+SHIFT,comma" "tagmon,prev,0" "Window → previous monitor")
    (b "SUPER+SHIFT,period" "tagmon,next,0" "Window → next monitor")

    # ── audio / media (perilla = XF86Audio*; Super+F-teclas como respaldo)
    (b "NONE,XF86AudioRaiseVolume" "spawn,${volUp}" null)
    (b "NONE,XF86AudioLowerVolume" "spawn,${volDown}" null)
    (b "NONE,XF86AudioMute" "spawn,${volMute}" null)
    (b "NONE,XF86AudioMicMute" "spawn,${micMute}" null)
    (b "NONE,XF86AudioPlay" "spawn,playerctl play-pause" null)
    (b "NONE,XF86AudioNext" "spawn,playerctl next" null)
    (b "NONE,XF86AudioPrev" "spawn,playerctl previous" null)
    (b "SUPER,F5" "spawn,${micMute}" "Mute microphone")
    (b "SUPER,F7" "spawn,playerctl previous" "Previous track")
    (b "SUPER,F8" "spawn,playerctl play-pause" "Play / pause")
    (b "SUPER,F9" "spawn,playerctl next" "Next track")
    (b "SUPER,F10" "spawn,${volMute}" "Mute (knob press too)")
    (b "SUPER,F11" "spawn,${volDown}" "Volume − (knob too)")
    (b "SUPER,F12" "spawn,${volUp}" "Volume + (knob too)")
  ]
  # Super+1..9 ver tag · +Shift mover · +Ctrl alternar vista · +Ctrl+Shift alternar tag
  ++ map (i: b "SUPER,${toString i}" "view,${toString i},0" null) tags
  ++ map (i: b "SUPER+SHIFT,${toString i}" "tag,${toString i},0" null) tags
  ++ map (i: b "SUPER+CTRL,${toString i}" "toggleview,${toString i}" null) tags
  ++ map (i: b "SUPER+CTRL+SHIFT,${toString i}" "toggletag,${toString i}" null) tags;

  # ---------------------------------------------------- chuleta (Super+/)
  prettyMod =
    m:
    {
      SUPER = "Super";
      SHIFT = "Shift";
      CTRL = "Ctrl";
      ALT = "Alt";
      NONE = "";
    }
    .${m} or m;
  prettyKey =
    k:
    {
      grave = "`";
      slash = "/";
      period = ".";
      comma = ",";
      semicolon = ";";
      minus = "-";
      equal = "=";
      space = "Space";
      bracketleft = "[";
      bracketright = "]";
    }
    .${k} or (if builtins.stringLength k == 1 then lib.toUpper k else k);
  prettyCombo =
    kk:
    let
      parts = lib.splitString "," kk;
      mods = lib.filter (x: x != "") (map prettyMod (lib.splitString "+" (builtins.head parts)));
    in
    lib.concatStringsSep "+" (mods ++ [ (prettyKey (lib.last parts)) ]);
  pad = n: s: s + lib.concatStrings (lib.genList (_: " ") (lib.max 1 (n - builtins.stringLength s)));
  cheatLines = map (x: "${pad 24 (prettyCombo x.k)}${x.d}") (lib.filter (x: x.d != null) binds) ++ [
    "${pad 24 "Super+1..9"}View tag"
    "${pad 24 "Super+Shift+1..9"}Move window to tag"
    "${pad 24 "Super+Ctrl+1..9"}Toggle tag view (add/remove)"
    "${pad 24 "Super+Ctrl+Shift+1..9"}Toggle window on tag"
    "${pad 24 "Super+Mouse L / R"}Move / resize window"
    "${pad 24 "Super+Wheel"}Previous / next busy tag"
    "${pad 24 "Helium start page"}/ search · Esc normal · letter opens link · ? help"
    ""
    "── Emacs (Doom) ── SPC = leader (which-key shows the rest)"
    "${pad 24 "SPC SPC / SPC ."}Find file in project / find file"
    "${pad 24 "SPC , / SPC /"}Switch buffer / search project (ripgrep)"
    "${pad 24 "C-h/j/k/l"}Window left/down/up/right"
    "${pad 24 "H / L"}Previous / next buffer"
    "${pad 24 "SPC w v / SPC w s"}Split vertical / horizontal"
    "${pad 24 "SPC o p / SPC o -"}dirvish sidebar / dired here (h/l = up/open)"
    "${pad 24 "SPC o t / SPC g g"}vterm popup / magit"
    "${pad 24 "SPC e / SPC b d"}Line diagnostics / delete buffer"
    "${pad 24 "SPC h t / SPC t o"}Pick theme (preview) / toggle transparency"
  ];
in
{
  wayland.windowManager.mango = {
    enable = true;
    systemd.enable = true;

    # Se escribe en ~/.config/mango/autostart.sh y se ejecuta con exec_once.
    # El módulo antepone la activación de systemd/dbus y el arranque de
    # mango-session.target (waybar y swaync dependen de él).
    autostart_sh = ''
      # Agente Spice de usuario (portapapeles compartido con el host).
      # Corre sobre XWayland; wlroots sincroniza el portapapeles con Wayland.
      # Se espera un poco a que XWayland exporte DISPLAY.
      (sleep 3; exec ${pkgs.spice-vdagent}/bin/spice-vdagent -x) &
    '';

    settings = xkbExtra // {
      # ---------------------------------------------------------- autostart
      # Wallpaper: awww (ver wallpapers.nix). Fallback stylix queda en hyprlock.
      exec_once = [ ];

      # ----------------------------------------------------------- monitor
      # VM a 2K: virtio-gpu no anuncia 2560x1440, se fuerza como modo custom.
      # Escala 1.5 (espacio lógico ~1707x960) para que el texto sea legible.
      monitor_rule = [
        "name:^Virtual-1$,width:2560,height:1440,refresh:60,x:0,y:0,scale:1.5,custom:1"
      ];

      # ---------------------------------------------------------------- env
      # (sin fcitx, iHD ni VDPAU: no aplican en la VM)
      env = [
        "GDK_BACKEND,wayland,x11"
        "QT_QPA_PLATFORM,wayland;xcb"
        "SDL_VIDEODRIVER,wayland"
        "CLUTTER_BACKEND,wayland"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "MOZ_ENABLE_WAYLAND,1"
        "_JAVA_AWT_WM_NONREPARENTING,1"
      ];

      # ---------------------------------------------------------- animation
      # Suaves pero ágiles (~300-400 ms), curva "ease-out" sin rebote.
      animations = 1;
      layer_animations = 1;
      animation_type_open = "zoom";
      animation_type_close = "zoom";
      animation_fade_in = 1;
      animation_fade_out = 1;
      tag_animation_direction = 1;
      zoom_initial_ratio = 0.85;
      zoom_end_ratio = 0.92;
      fade_in_begin_opacity = 0.4;
      fade_out_begin_opacity = 0.9;
      animation_duration_move = 320;
      animation_duration_open = 320;
      animation_duration_tag = 360;
      animation_duration_close = 260;
      animation_duration_focus = 240;
      animation_curve_open = "0.22,1,0.36,1";
      animation_curve_move = "0.22,1,0.36,1";
      animation_curve_tag = "0.22,1,0.36,1";
      animation_curve_close = "0.4,0,0.2,1";
      animation_curve_focus = "0.22,1,0.36,1";
      animation_curve_opacity_fade_out = "0.4,0,0.2,1";
      animation_curve_opacity_fade_in = "0.22,1,0.36,1";

      # ------------------------------------------------------------- layout
      scroller_structs = 20;
      scroller_default_proportion = 0.5;
      scroller_focus_center = 0;
      scroller_prefer_center = 1;
      edge_scroller_pointer_focus = 1;
      scroller_ignore_proportion_single = 1;
      scroller_default_proportion_single = 1.0;
      scroller_proportion_preset = "0.5,0.8,1.0";

      new_is_master = 1;
      smart_gaps = 0;
      default_master_factor = 0.55;
      default_master_count = 1;

      dwindle_smart_split = 0;
      dwindle_drop_simple_split = 1;
      dwindle_manual_split = 0;
      dwindle_horizontal_split = 1;
      dwindle_vertical_split = 1;
      dwindle_preserve_split = 1;

      # ------------------------------------------------------------- effect
      # Moderado para virgl: blur ligero (solo ventanas translúcidas, p. ej.
      # kitty), sombras suaves. Si la VM va lenta: blur = 0 y shadows = 0.
      blur = 1;
      blur_layer = 0;
      blur_optimized = 1;
      blur_params_num_passes = 2;
      blur_params_radius = 6;
      blur_params_noise = 0.02;
      blur_params_brightness = 0.95;
      blur_params_contrast = 1.0;
      blur_params_saturation = 1.25;

      shadows = 1;
      layer_shadows = 0;
      shadow_only_floating = 0;
      shadows_size = 14;
      shadows_blur = 18;
      shadows_position_x = 0;
      shadows_position_y = 4;
      shadows_color = "0x0a061280";

      border_radius = 14;
      no_radius_when_single = 0;
      focused_opacity = 1.0;
      unfocused_opacity = 0.94;

      # ----------------------------------------------------------- settings
      hotarea_size = 10;
      enable_hotarea = 1;
      overview_gap_inner = 10;
      overview_gap_outer = 20;

      xwayland_persistence = 1;
      sync_obj_enable = 0;
      no_border_when_single = 0;
      axis_bind_apply_timeout = 100;
      focus_on_activate = 1;
      sloppy_focus = 1;
      warp_cursor = 1;
      focus_cross_monitor = 0;
      focus_cross_tag = 0;
      # Super+Space recorre estas distribuciones (switch_layout).
      circle_layout = "scroller,tile,monocle,grid,deck,dwindle";
      enable_floating_snap = 1;
      snap_distance = 20;
      cursor_hide_timeout = 0;
      cursor_size = config.stylix.cursor.size;
      cursor_theme = config.stylix.cursor.name;
      drag_tile_to_tile = 1;
      single_scratchpad = 1;

      # Teclado: se toma la distribución del configuration.nix del instalador.
      repeat_rate = 25;
      repeat_delay = 600;
      numlock_on = 1;
      xkb_rules_layout = if xkb.layout != "" then xkb.layout else "us";

      disable_trackpad = 0;
      tap_to_click = 1;
      tap_and_drag = 1;
      drag_lock = 1;
      mouse_natural_scrolling = 0;
      trackpad_natural_scrolling = 0;
      swipe_min_threshold = 1;
      mouse_accel_profile = 2;
      mouse_accel_speed = 0.0;

      gap_inner_horizontal = 10;
      gap_inner_vertical = 10;
      gap_outer_horizontal = 14;
      gap_outer_vertical = 12;
      scratchpad_width_ratio = 0.9;
      scratchpad_height_ratio = 0.9;

      # ------------------------------------------------- colores (stylix)
      # (mango 0.18 no tiene bordes en degradado: foco morado sólido,
      # inactivos violeta apagado casi invisible.)
      border_px = 2;
      root_color = rgba c.base00 "ff";
      border_color = rgba c.base02 "ff";
      focus_color = rgba c.base0D "ff";
      urgent_color = rgba c.base08 "ff";
      maximized_screen_color = rgba c.base0E "ff";
      scratchpad_color = rgba c.base0C "ff";
      global_color = rgba c.base09 "ff";
      overlay_color = rgba c.base0B "ff";
      drop_color = rgba c.base0D "55";
      split_color = rgba c.base08 "ff";

      # -------------------------------------------------------------- rules
      tag_rule = map (i: "id:${toString i},layout_name:scroller") tags;

      layer_rule = [
        "animation_type_open:slide,layer_name:swaync-control-center"
        "animation_type_close:slide,layer_name:swaync-control-center"
        "no_shadow:1,layer_name:swaync-control-center"
        "animation_type_open:slide,layer_name:rofi"
        "animation_type_close:slide,layer_name:rofi"
        "no_shadow:1,layer_name:rofi"
        "no_shadow:1,layer_name:waybar"
        "animation_type_open:zoom,layer_name:wlogout"
        "animation_type_close:zoom,layer_name:wlogout"
        "no_shadow:1,layer_name:wlogout"
      ];

      window_rule = [
        "scroller_proportion:1.0,app_id:firefox"
        "scroller_proportion:0.65,app_id:thunar"
        "scroller_proportion:1.0,app_id:helium"
        "scroller_proportion:0.65,app_id:io.github.lgse.Strata"
        "is_floating:1,app_id:pavucontrol"
        "is_floating:1,app_id:org.pulseaudio.pavucontrol"
        "is_floating:1,title:Confirm to replace files*"
        "is_floating:1,title:File Operation Progress*"
        # Lanzadores de teclado (Super+Shift+Return, Super+M, Ctrl+W)
        "is_floating:1,width:1100,height:700,app_id:kitty-float"
        "is_floating:1,width:1200,height:760,app_id:kitty-btop"
        "is_floating:1,width:900,height:600,app_id:kitty-nmtui"
        # Scratchpad con nombre (Super+grave)
        "is_named_scratchpad:1,width:1280,height:800,app_id:kitty-scratch"
      ];

      # -------------------------------------------------------------- binds
      # Generados desde `binds` (ver arriba); la misma lista produce la
      # chuleta de Super+/ (~/.config/mango/keybinds.txt).
      bind = map (x: "${x.k},${x.a}") binds;

      mousebind = [
        "SUPER,btn_left,moveresize,curmove"
        "SUPER,btn_right,moveresize,curresize"
        "SUPER+CTRL,btn_middle,togglefullscreen"
      ];

      axisbind = [
        "SUPER,UP,viewtoleft_have_client,0"
        "SUPER,DOWN,viewtoright_have_client,0"
      ];
    };
  };

  # ------------------------------------------- chuleta, portapapeles, menús
  xdg.configFile."mango/keybinds.txt".text = lib.concatStringsSep "\n" cheatLines + "\n";

  services.cliphist.enable = true; # wl-paste --watch cliphist store

  programs.rofi.plugins = [ pkgs.rofi-calc ];

  home.packages = [
    pkgs.cliphist
    pkgs.rofimoji
    pkgs.playerctl
    (pkgs.writeShellScriptBin "mango-keybinds" ''
      # Lista de atajos generada desde home/s1b/mango.nix (solo lectura).
      exec rofi -dmenu -i -no-custom -p "Keybinds" -theme-str 'window { width: 760px; } listview { lines: 16; }' \
        < "''${XDG_CONFIG_HOME:-$HOME/.config}/mango/keybinds.txt" >/dev/null
    '')
    (pkgs.writeShellScriptBin "mango-clipboard" ''
      # Historial del portapapeles (cliphist) → rofi → wl-copy
      sel=$(cliphist list | rofi -dmenu -i -p "Clipboard") || exit 0
      [ -n "$sel" ] && printf '%s' "$sel" | cliphist decode | wl-copy
    '')
  ];
}
