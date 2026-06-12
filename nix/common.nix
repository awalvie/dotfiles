{ config, pkgs, lib, user, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  # clipboard + open commands differ per OS. wl-copy on linux/wayland,
  # pbcopy/open on macos. injected into zsh below; tmux handles its own
  # split via if-shell in .tmux.conf.
  clip     = if isDarwin then "pbcopy" else "wl-copy";
  openCmd  = if isDarwin then "open"   else "xdg-open";
in
{
  home.username      = user;
  home.homeDirectory = if isDarwin then "/Users/${user}" else "/home/${user}";
  home.stateVersion  = "24.05";

  # cross-platform CLI surface. OS-specific packages (nixGL-wrapped alacritty,
  # keyd, clipboard tools, fontconfig) live in linux.nix / darwin.nix.
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
    direnv
    nerd-fonts.iosevka-term
  ];

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

    # global gitignore (~/.config/git/ignore). keeps direnv/venv artifacts out
    # of every repo's status — esp. the monorepo, where venvs are centralized
    # in ~/venvs via the direnv layout_uv above.
    ignores = [
      ".envrc"
      ".venv"
      ".direnv"
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

    # layout_uv: keep python venvs centralized in ~/venvs/<name> (out of the
    # repo, so they don't pollute the monorepo) and auto-activate on cd via
    # direnv. Usage in a project's .envrc:
    #   layout uv [name] [python-version]
    # `name` defaults to the basename of the .envrc's directory; for a monorepo
    # drop one .envrc at the root and it covers every subdir.
    stdlib = ''
      layout_uv() {
        local venv_name="''${1:-$(basename "$PWD")}"
        local py="''${2:-}"
        export UV_PROJECT_ENVIRONMENT="$HOME/venvs/$venv_name"

        if [[ ! -d "$UV_PROJECT_ENVIRONMENT" ]]; then
          log_status "uv: creating venv '$venv_name' at $UV_PROJECT_ENVIRONMENT"
          if [[ -n "$py" ]]; then
            uv venv --python "$py" "$UV_PROJECT_ENVIRONMENT"
          else
            uv venv "$UV_PROJECT_ENVIRONMENT"
          fi
        fi

        export VIRTUAL_ENV="$UV_PROJECT_ENVIRONMENT"
        PATH_add "$VIRTUAL_ENV/bin"
      }
    '';
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
      o     = openCmd;

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

      dps = "docker ps --format 'table {{ .ID }}\\t{{.Names}}\\t{{.Status}}'";

      gc   = "git commit -v -s";
      gst  = "git status --short";
      ga   = "git add";
      gd   = "git diff --minimal";
      gl   = "git log --oneline --decorate --graph";
      gdc  = "git diff --cached";
      gcan = "git commit --amend --no-edit";
    };

    initContent = ''
      export KEYTIMEOUT=1
      bindkey -v '^?' backward-delete-char

      function vi-yank-clip {
        zle vi-yank
        echo "$CUTBUFFER" | ${clip}
      }
      zle -N vi-yank-clip
      bindkey -M vicmd 'y' vi-yank-clip

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

  # config-file symlinks shared by both OSes. alacritty reads ~/.config/alacritty
  # on macos too, so the config symlink is shared; only the package differs.
  xdg.configFile = {
    "nvim"      = { source = ../config/nvim;      recursive = true; };
    "alacritty" = { source = ../config/alacritty; recursive = true; };
    "lazygit"   = { source = ../config/lazygit;   recursive = true; };
  };

  home.file = {
    ".tmux.conf".source = ../home/.tmux.conf;

    # ssh host aliases (github accounts + a few servers). The referenced
    # IdentityFiles (~/.ssh/<name>) are per-machine and NOT in the repo.
    ".ssh/config".source = ../config/ssh/config;

    "bin" = {
      source    = ../home/bin;
      recursive = true;
    };
  };

  # Project workspace dirs. No sudo, no script — just ensure they exist.
  home.activation.setupCodeDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p \
      ${config.home.homeDirectory}/code/origin \
      ${config.home.homeDirectory}/code/lamp \
      ${config.home.homeDirectory}/code/work
  '';
}
