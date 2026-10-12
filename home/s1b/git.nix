# Git: alias, firma de commits con SSH, delta como pager y ssh-agent.
# La clave pública NO va en el repo: allowed_signers se genera al activar
# a partir de ~/.ssh/id_ed25519.pub de la máquina.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  c = config.lib.stylix.colors;
  h = config.lib.stylix.colors.withHashtag;
  home = config.home.homeDirectory;
  email = "ind4skylivey@users.noreply.github.com";
  pubKey = "${home}/.ssh/id_ed25519.pub";
  allowedSigners = "${config.xdg.configHome}/git/allowed_signers";

  # Mezcla un color base16 sobre el fondo (base00) al pct% → fondos de diff suaves.
  blend =
    base: pct:
    let
      ch =
        x:
        let
          f = lib.toInt c."${base}-rgb-${x}";
          b = lib.toInt c."base00-rgb-${x}";
        in
        lib.fixedWidthString 2 "0" (lib.toLower (lib.toHexString (b + (f - b) * pct / 100)));
    in
    "#${ch "r"}${ch "g"}${ch "b"}";
in
{
  programs.git = {
    enable = true;
    signing = {
      format = "ssh";
      key = pubKey;
      signByDefault = true;
    };
    settings = {
      user.name = "ind4skylivey";
      user.email = email;
      init.defaultBranch = "main";
      pull.rebase = true;
      core.quotepath = false;
      merge.conflictStyle = "zdiff3";
      diff.colorMoved = "default";
      gpg.ssh.allowedSignersFile = allowedSigners;
      url."git@github.com:".insteadOf = "https://github.com/";
      alias = {
        st = "status -sb";
        co = "checkout";
        cm = "commit -m";
        pf = "push --force-with-lease";
        lg = "log --graph --abbrev-commit --date=relative --pretty=format:'%C(magenta)%h%C(reset) %C(red)%d%C(reset) %s %C(dim)(%cr) <%an>%C(reset)'";
        wa = "worktree add";
        wl = "worktree list";
        wd = "worktree remove";
        latest = "describe --tags --abbrev=0";
      };
    };
  };

  home.activation.gitAllowedSigners = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [[ -r "${pubKey}" && ! -v DRY_RUN ]]; then
      mkdir -p "$(dirname "${allowedSigners}")"
      printf '%s namespaces="git" %s\n' "${email}" \
        "$(${pkgs.coreutils}/bin/cut -d' ' -f1,2 "${pubKey}")" > "${allowedSigners}"
    fi
  '';

  # ------------------------------------------------------------ delta
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = false;
      line-numbers = true;
      dark = true;
      syntax-theme = "base16"; # usa los 16 colores ANSI de kitty (stylix)
      file-style = "bold ${h.base0D}";
      file-decoration-style = "${h.base0D} ul";
      hunk-header-style = "file line-number syntax";
      hunk-header-decoration-style = "${h.base0E} box";
      commit-decoration-style = "${h.base0E} box";
      minus-style = "syntax ${blend "base08" 22}";
      minus-emph-style = "syntax ${blend "base08" 45}";
      plus-style = "syntax ${blend "base0B" 15}";
      plus-emph-style = "syntax ${blend "base0B" 35}";
      line-numbers-minus-style = h.base08;
      line-numbers-plus-style = h.base0B;
      line-numbers-zero-style = h.base03;
      line-numbers-left-style = h.base02;
      line-numbers-right-style = h.base02;
      blame-palette = "${h.base00} ${h.base01} ${h.base02}";
    };
  };

  # ------------------------------------------------------------ ssh-agent
  # La clave tiene passphrase: se pide una vez por sesión y queda en el agente.
  services.ssh-agent.enable = true;
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = {
      AddKeysToAgent = "yes";
      ServerAliveInterval = 60;
    };
  };
}
