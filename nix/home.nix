{ config, pkgs, lib, user, nixgl, ... }:

let
  # nixGL wrapper that injects the host NVIDIA driver paths at runtime.
  nixGL = nixgl.packages.${pkgs.stdenv.hostPlatform.system}.nixGLDefault;

  # alacritty, but with its `bin/alacritty` wrapped through nixGL. symlinkJoin
  # keeps the original /share (desktop entry + icon) intact, so the launcher
  # entry that setup-alacritty.sh generates points at the GL-correct binary.
  alacrittyGL = pkgs.symlinkJoin {
    name               = "alacritty-nixgl";
    paths              = [ pkgs.alacritty ];
    nativeBuildInputs  = [ pkgs.makeWrapper ];
    postBuild = ''
      rm $out/bin/alacritty
      makeWrapper ${nixGL}/bin/nixGL $out/bin/alacritty \
        --add-flags ${pkgs.alacritty}/bin/alacritty
    '';
  };
in
{
  home.username      = user;
  home.homeDirectory = "/home/${user}";
  home.stateVersion  = "24.05";

  home.packages = with pkgs; [
    neovim
    tmux
    lazygit
    bat
    fzf
    ripgrep
    fd
    tree
    jq
    curl
    wget
    unzip
    xclip
    wl-clipboard
    go
    rustup
    nodejs_22
    python3
    uv
    cmake
    gnumake
    gcc
    pkg-config
    tree-sitter
    stylua
    git
    delta
    alacrittyGL
    direnv
    fontconfig
    nerd-fonts.iosevka-term
    keyd
  ];

  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate   = true;
      true-color = "always";
      features   = "arctic-fox";
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user.name  = "awalvie";
      user.email = "agrawal.vishesh.178@gmail.com";
      merge.conflictstyle = "diff3";
      diff.colorMoved     = "default";
    };

    includes = [
      { path = "~/dotfiles/config/delta/themes.gitconfig"; }
    ];
  };

  programs.fzf = {
    enable               = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--color=bg:#2E3440,bg+:#434C5E"
      "--color=spinner:#88C0D0,hl:#81A1C1"
      "--color=fg:#D8DEE9,header:#81A1C1"
      "--color=info:#EBCB8B,pointer:#88C0D0"
      "--color=marker:#A3BE8C,fg+:#ECEFF4"
      "--color=prompt:#8FBCBB,hl+:#5E81AC"
      "--layout=reverse"
    ];
  };

  programs.bat = {
    enable = true;
    config.theme = "Nord";
  };

  programs.direnv = {
    enable               = true;
    enableZshIntegration = true;
    nix-direnv.enable    = true;
  };

  programs.zsh = {
    enable                    = true;
    autosuggestion.enable     = true;
    syntaxHighlighting.enable = true;
    enableCompletion          = true;
    defaultKeymap             = "viins";

    history = {
      size          = 10000;
      save          = 10000;
      ignoreDups    = true;
      ignoreAllDups = true;
      share         = true;
      extended      = true;
    };

    shellAliases = {
      vim   = "nvim";
      lg    = "lazygit";
      untar = "tar xvzf";
      sjson = "tr -d '\\n'";
      cat   = "bat";
      o     = "xdg-open";
      xclip = "xclip -selection clipboard";

      ls = "ls --color=auto";
      ll = "ls -alF";
      la = "ls -A";
      l  = "ls -CF";

      zshconfig = "vim ~/.zshrc";
      vimconfig = "vim ~/.config/nvim/init.lua";
      dotfiles  = "cd ~/dotfiles";

      tn = "tmux new -s";
      tl = "tmux ls";
      ta = "tmux attach";

      k   = "kubectl";
      kd  = "kubectl describe";
      kg  = "kubectl get";
      kgy = "kubectl get -o yaml";

      dps = "docker ps --format 'table {{ .ID }}\\t{{.Names}}\\t{{.Status}}'";

      gc   = "git commit -v -s";
      gst  = "git status --short";
      ga   = "git add";
      gd   = "git diff --minimal";
      gl   = "git log --oneline --decorate --graph";
      gdc  = "git diff --cached";
      gcan = "git commit --amend --no-edit";

      hms = "NIXPKGS_ALLOW_UNFREE=1 home-manager switch --flake ~/dotfiles#default --impure";
    };

    initContent = ''
      export KEYTIMEOUT=1
      bindkey -v '^?' backward-delete-char

      function vi-yank-xclip {
        zle vi-yank
        echo "$CUTBUFFER" | xclip -selection clipboard
      }
      zle -N vi-yank-xclip
      bindkey -M vicmd 'y' vi-yank-xclip

      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey -M vicmd " " edit-command-line

      function ... { cd ../.. }
      function .... { cd ../../.. }
      function d { [[ $1 =~ '^[0-9]+$' ]] && cd $(printf '../%.0s' {1..$1}) || cd .. }

      fpath+=(${pkgs.pure-prompt}/share/zsh/site-functions)
      autoload -U promptinit; promptinit
      prompt pure

      source ${pkgs.zsh-z}/share/zsh-z/zsh-z.plugin.zsh

      [[ -f "$HOME/bin/uvenv" ]] && source "$HOME/bin/uvenv"

      export EDITOR='nvim'
      export GOPATH=$HOME/go
      export GPG_TTY=$(tty)
      path=(
        $HOME/bin
        $GOPATH/bin
        $HOME/.local/bin
        $path
      )
      typeset -U path
    '';
  };

  xdg.configFile = {
    "nvim"      = { source = ../config/nvim;      recursive = true; };
    "alacritty" = { source = ../config/alacritty; recursive = true; };
    "lazygit"   = { source = ../config/lazygit;   recursive = true; };
  };

  home.file = {
    ".tmux.conf".source = ../home/.tmux.conf;
    ".Xmodmap".source   = ../home/.Xmodmap;

    "bin" = {
      source    = ../home/bin;
      recursive = true;
    };
  };

  # Per-program setup for things nix/home-manager can't manage declaratively on
  # a non-NixOS host. Each program gets its own script in scripts/.
  home.activation.setupKeyd = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH=/usr/bin:/bin:$PATH
    ${../scripts/setup-keyd.sh} \
      ${pkgs.keyd}/bin/keyd \
      ${../home/keyd/default.conf}
  '';

  home.activation.setupAlacritty = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH=/usr/bin:/bin:$PATH
    ${../scripts/setup-alacritty.sh} \
      ${alacrittyGL}
  '';

  home.activation.setupZsh = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH=/usr/bin:/bin:$PATH
    ${../scripts/setup-zsh.sh} \
      ${config.home.profileDirectory}/bin/zsh \
      ${user}
  '';

  # Project workspace dirs. No sudo, no script — just ensure they exist.
  home.activation.setupCodeDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p \
      ${config.home.homeDirectory}/code/origin \
      ${config.home.homeDirectory}/code/lamp \
      ${config.home.homeDirectory}/code/work
  '';
}
