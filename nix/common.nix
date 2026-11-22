{ config, pkgs, lib, user, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  # clipboard + open commands differ per OS. wl-copy on linux/wayland,
  # pbcopy/open on macos. injected into zsh below; tmux handles its own
  # split via if-shell in .tmux.conf.
  clip     = if isDarwin then "pbcopy" else "wl-copy";
  openCmd  = if isDarwin then "open"   else "xdg-open";
  # macOS ships BSD ls (no --color=auto); use -G there.
  lsCmd    = if isDarwin then "ls -G"  else "ls --color=auto";

  # Out-of-store link to the checkout: edits apply at once, without `hms`, and
  # the program can write the file back.
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/${path}";
  # The checkout, for out-of-store links. Host modules get it as `dotfiles`.
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  # A file of the current theme variant (see home/bin/theme).
  themeFile = name: "${config.home.homeDirectory}/.local/state/theme/current/${name}";
in
{
  _module.args.dotfiles = dotfiles;

  home.username      = user;
  home.homeDirectory = if isDarwin then "/Users/${user}" else "/home/${user}";
  home.stateVersion  = "24.05";

  # No "unread news items" notice after each switch (`home-manager news` still works).
  news.display = "silent";

  # cross-platform CLI surface. OS-specific packages (nixGL-wrapped alacritty,
  # keyd, clipboard tools, fontconfig) live in linux.nix / hosts/darwin.nix.
  home.packages = with pkgs; [
    neovim
    tmux
    lazygit
    btop
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
    gh
    kubectl
    argocd
    yt-dlp
    ffmpeg
    delta
    direnv
    nerd-fonts.iosevka-term
  ];

  programs.home-manager.enable = true;

  # module comes from the sofka flake input (see flake.nix); the skin comes
  # from the current theme variant through conf.d (see xdg.configFile below)
  programs.sofka.enable = true;

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate   = true;
      true-color = "always";
      syntax-theme = "ansi";
      file-added-label    = "[+]";
      file-copied-label   = "[==]";
      file-modified-label = "[*]";
      file-removed-label  = "[-]";
      file-renamed-label  = "[->]";
      file-style = "omit";
      hunk-header-decoration-style    = "blue ul";
      hunk-header-file-style          = "blue ul bold";
      hunk-header-line-number-style   = "yellow box bold";
      hunk-header-style               = "file line-number syntax bold italic";
      plus-style          = "brightgreen";
      plus-emph-style     = "black green";
      minus-style         = "brightred";
      minus-emph-style    = "black red";
      line-numbers        = true;
      line-numbers-minus-style = "brightred";
      line-numbers-plus-style  = "brightgreen";
      line-numbers-left-style  = "blue";
      line-numbers-right-style = "blue";
      line-numbers-zero-style  = "brightblack";
      zero-style          = "syntax";
      whitespace-error-style = "black bold";
      blame-code-style    = "syntax";
      blame-format        = "{author:<18} {commit:<6} {timestamp:<15}";
      merge-conflict-begin-symbol = "~";
      merge-conflict-end-symbol   = "~";
      merge-conflict-ours-diff-header-style   = "yellow bold";
      merge-conflict-ours-diff-header-decoration-style   = "blue box";
      merge-conflict-theirs-diff-header-style = "yellow bold";
      merge-conflict-theirs-diff-header-decoration-style = "blue box";
    };
  };

  programs.git = {
    enable = true;

    lfs.enable = true;

    # delta's dark/light flag, from the current theme variant (a missing file
    # is skipped); terminal detection can fail inside tmux
    includes = [{ path = themeFile "delta.gitconfig"; }];

    settings = {
      user.name  = "awalvie";
      user.email = "agrawal.vishesh.178@gmail.com";
      merge.conflictstyle = "diff3";
      diff.colorMoved     = "default";

      # push to GitHub over ssh (key: ~/.ssh/github, see home/.ssh/config).
      # Clones and fetches stay on https, so a new host can clone before it
      # has a key.
      url."git@github.com:".pushInsteadOf = "https://github.com/";
    };

    # global gitignore (~/.config/git/ignore). keeps direnv/venv artifacts out
    # of every repo's status — esp. the monorepo, where venvs are centralized
    # in ~/venvs via the direnv layout_uv above.
    ignores = [
      ".envrc"
      ".venv"
      ".direnv"
    ];
  };

  # yazi terminal file manager. `y` opens it and, on quit, cd's the shell into
  # the folder yazi was in.
  programs.yazi = {
    enable               = true;
    enableZshIntegration = true;
    shellWrapperName     = "y";
    # Official Rosé Pine flavours; yazi picks Moon or Dawn from the terminal's
    # background when it starts, so it follows the theme switch by itself.
    flavors = let
      rosePine = pkgs.fetchFromGitHub {
        owner = "rose-pine";
        repo  = "yazi";
        rev   = "c89d745573d4fcfe0550fe6646f9f9ab1c0e51db";
        hash  = "sha256-9e3dXViWl1rK9BPrGAFfs9ZL/tsG6Njz6ksuU6AIrFY=";
      };
    in {
      rose-pine-moon = "${rosePine}/flavors/rose-pine-moon.yazi";
      rose-pine-dawn = "${rosePine}/flavors/rose-pine-dawn.yazi";
    };
    theme.flavor = {
      dark  = "rose-pine-moon";
      light = "rose-pine-dawn";
    };
  };

  programs.zoxide = {
    enable               = true;
    enableZshIntegration = true;
    # keeps the `z`/`zi` commands (zoxide's defaults) — same muscle memory as
    # the zsh-z it replaced.
  };

  programs.fzf = {
    enable               = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--layout=reverse"
    ];
  };

  programs.bat = {
    enable = true;
    config.theme = "ansi";
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

      ls = lsCmd;
      ll = "ls -alF";
      la = "ls -A";
      l  = "ls -CF";

      zshconfig = "vim ~/.zshrc";
      vimconfig = "vim ~/.config/nvim/init.lua";
      dotfiles  = "cd ~/dotfiles";

      # Personal Claude account; plain `claude` stays on ~/.claude (work).
      claude-personal = "CLAUDE_CONFIG_DIR=$HOME/.claude-personal claude";

      tn = "tmux new -s";
      tl = "tmux ls";
      ta = "tmux attach";

      k   = "kubectl";
      kd  = "kubectl describe";
      kg  = "kubectl get";
      kgy = "kubectl get -o yaml";
      kui = "sofka";

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

      # Navigation QoL (HM sets the history setopts for us, not these):
      #   AUTO_CD            — `dir` instead of `cd dir`
      #   AUTO_PUSHD + dups  — every cd builds a stack; `cd -<Tab>` to jump back
      #   INTERACTIVE_COMMENTS — allow `#` comments when pasting/typing
      setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT INTERACTIVE_COMMENTS

      # File colors, shared by `ls --color` and the completion menu (the
      # list-colors zstyle below reads $LS_COLORS). Uses ANSI slot numbers
      # rather than raw hex, so they render in whatever the terminal palette
      # maps those slots to (34 blue, 36 cyan, 32 green, 35 magenta, 33 yellow,
      # 31 red) and follow a terminal theme change automatically.
      export LS_COLORS="di=34:ln=36:so=35:pi=33:ex=32:bd=33:cd=33:su=31:sg=31:tw=34:ow=34:or=31:mi=31:*.tar=35:*.tgz=35:*.gz=35:*.zip=35:*.7z=35:*.jpg=35:*.jpeg=35:*.png=35:*.gif=35:*.mp4=35:*.mkv=35:*.mp3=35"

      # Tab completion: navigable, highlighted menu + ls-style colors. HM's
      # generated zshrc runs `compinit` but sets no completion zstyles, so the
      # default (plain, non-navigable) listing applies; restore the menu here.
      zstyle ':completion:*' menu select
      # candidates use $LS_COLORS (above); ma= is the selected-item highlight
      # bar — palette blue bg (slot 4) with the palette black fg (slot 0).
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}" 'ma=48;5;4;38;5;0'
      # case-insensitive, then substring matching (`cd dwn` -> `Downloads`).
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'l:|=* r:|=*'
      # cache slow completions (e.g. apt/dpkg) under XDG.
      zstyle ':completion:*' use-cache on
      zstyle ':completion:*' cache-path "''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

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

      # Try a program without installing it: `nr cmatrix`, `nr gping 1.1.1.1`
      # (nix run), or `ns gping trippy` for a shell that has them (nix shell).
      function nr { local p=$1; shift; nix run "nixpkgs#$p" -- "$@" }
      # NS_PKGS names them for the prompt (nix shell sets no variable of its own).
      function ns { NS_PKGS="''${NS_PKGS:+$NS_PKGS }$*" nix shell "''${@/#/nixpkgs#}" }

      fpath+=(${pkgs.pure-prompt}/share/zsh/site-functions)
      autoload -U promptinit; promptinit
      prompt pure

      # Gold `hms` on the right while the applied setup differs from the repo.
      function _hms_marker {
        if ${../scripts/hms-state.sh} check; then
          RPROMPT='%F{yellow}hms%f'
        else
          RPROMPT=""
        fi
      }
      # `ns: <pkgs> ❯` inside an `ns` shell, in pure's virtualenv slot
      # (psvar[20]); runs after pure's precmd, which clears it.
      function _ns_marker {
        [[ -n $NS_PKGS ]] && psvar[20]="ns: $NS_PKGS"
      }
      autoload -Uz add-zsh-hook
      add-zsh-hook precmd _hms_marker
      add-zsh-hook precmd _ns_marker

      # Tab completion for the `theme` command (home/bin/theme).
      function _theme {
        local -a cmds=(list set toggle apply init help)
        case $CURRENT:$words[2] in
          2:*) _describe command cmds ;;
          3:set) _files -W ~/.config/themes -/ ;;
          3:apply) _values mode dark light ;;
        esac
      }
      compdef _theme theme

      export EDITOR='nvim'
      export GOPATH=$HOME/go
      export GPG_TTY=$(tty)
      # nix tools before the system's (CachyOS ships its own tmux, for one);
      # typeset -U keeps the first copy of each entry.
      path=(
        $HOME/bin
        $GOPATH/bin
        $HOME/.local/bin
        ${config.home.profileDirectory}/bin
        $path
      )
      typeset -U path
    '';
  };

  # config-file symlinks shared by both OSes. alacritty reads ~/.config/alacritty
  # on macos too, so the config symlink is shared; only the package differs.
  xdg.configFile = {
    # nvim's byte-code cache misses edits to store files (same mtime), so link
    # the checkout itself.
    "nvim".source = link "nvim";
    "alacritty" = { source = ../config/alacritty; recursive = true; };
    "lazygit"   = { source = ../config/lazygit;   recursive = true; };
    "btop/themes/current.theme".source = config.lib.file.mkOutOfStoreSymlink (themeFile "btop.theme");
    "sofka/conf.d/10-theme.toml".source = config.lib.file.mkOutOfStoreSymlink (themeFile "sofka.toml");
    # theme variants; the `current` link in ~/.local/state/theme points into
    # this folder, so it must resolve to the checkout, not the store.
    "themes".source = link "themes";

    # ~/.config/nix/nix.conf — enables flakes + the new nix CLI. Managed as a
    # plain symlink rather than via the HM `nix.*` module on purpose: that
    # module shells out to `nix` (needing nix-command) during activation, which
    # deadlocks on a non-NixOS host where this very file is what enables the
    # feature. A flat symlink has no activation-time nix invocation. Note this
    # is only the *steady-state* owner — the first `home-manager switch` on a
    # fresh machine still needs the feature enabled by hand (see CLAUDE.md).
    "nix/nix.conf".source = ../config/nix/nix.conf;
  };

  home.file = {
    ".tmux.conf".source = ../home/.tmux.conf;
    # tmux plugins from nixpkgs (no tpm), loaded at the end of .tmux.conf.
    # resurrect: prefix+C-s saves sessions, prefix+C-r restores them;
    # continuum saves every 15 min and restores when the tmux server starts.
    ".tmux-plugins.conf".text = ''
      set -g @resurrect-capture-pane-contents 'on'
      set -g @continuum-restore 'on'
      run-shell ${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/resurrect.tmux
      run-shell ${pkgs.tmuxPlugins.continuum}/share/tmux-plugins/continuum/continuum.tmux
    '';

    # ssh host aliases (github accounts + a few servers). The referenced
    # IdentityFiles (~/.ssh/<name>) are per-machine and NOT in the repo.
    ".ssh/config".source = ../home/.ssh/config;

    "bin" = {
      source    = ../home/bin;
      recursive = true;
    };
  };

  # Record the repo state this switch applied, for the prompt's `hms` marker.
  home.activation.recordHmsState = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH=${pkgs.git}/bin:/usr/bin:/bin:$PATH
    $DRY_RUN_CMD ${../scripts/hms-state.sh} record
  '';

  # Default theme link (Rosé Pine, desktop mode), only when it is missing.
  home.activation.setupTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH=${pkgs.coreutils}/bin:${pkgs.gnused}/bin:$PATH
    $DRY_RUN_CMD ${../home/bin/theme} init
  '';

  # btop rewrites btop.conf whenever a setting changes, so it gets a local,
  # writable copy of the repo's file, made only when it is missing (or still
  # the old link into the repo). The copy keeps color_theme = "current".
  home.activation.setupBtop = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    f=${config.xdg.configHome}/btop/btop.conf
    if [ -L "$f" ] || [ ! -e "$f" ]; then
      $DRY_RUN_CMD rm -f "$f"
      $DRY_RUN_CMD install -Dm644 ${../config/btop/btop.conf} "$f"
    fi
  '';

  # Project workspace dirs. No sudo, no script — just ensure they exist.
  home.activation.setupCodeDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p \
      ${config.home.homeDirectory}/code/origin \
      ${config.home.homeDirectory}/code/lamp \
      ${config.home.homeDirectory}/code/work
  '';
}
