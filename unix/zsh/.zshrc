# ============================================================================
# Environment Variables
# ============================================================================

# Core settings
export EDITOR='nvim'
export ZSH="$HOME/.oh-my-zsh" # Deprecated, kept for reference
export GOPATH=$HOME/go
export BAT_THEME="Nord"

# GPG configuration
export GPG_TTY=$(tty)

# Path configuration
path=(
  $HOME/bin
  /usr/local/go/bin
  $GOPATH/bin
  $HOME/.local/share/bob/nvim-bin
  $PATH/.local/bin
  $path
)

# Remove duplicates from PATH
typeset -U path

# ============================================================================
# History Configuration
# ============================================================================

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt append_history             # Append history instead of overwriting
setopt hist_ignore_dups           # Ignore duplicate commands
setopt hist_ignore_all_dups       # Remove older duplicate entries
setopt hist_reduce_blanks         # Remove superfluous blanks
setopt share_history              # Share history across all sessions
setopt inc_append_history         # Immediately append new history lines
setopt extended_history           # Save timestamp for each command

# ============================================================================
# Zsh Configuration
# ============================================================================

# Enable colors for ls and other commands
autoload -U colors && colors

# Initialize completion system
autoload -Uz compinit
compinit

# ============================================================================
# Completion Configuration
# ============================================================================

# Case-insensitive completion + menu selection
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ''

# ============================================================================
# Zsh Options
# ============================================================================

setopt auto_cd no_beep

# ============================================================================
# Functions
# ============================================================================

# Directory navigation functions
function ... { cd ../.. }
function .... { cd ../../.. }
function d { [[ $1 =~ '^[0-9]+$' ]] && cd $(printf '../%.0s' {1..$1}) || cd .. }

# ============================================================================
# Plugin Management
# ============================================================================

ZSH_PLUGINS_DIR="$HOME/.zsh_plugins"

# Create plugins directory if it doesn't exist
[[ ! -d "$ZSH_PLUGINS_DIR" ]] && mkdir -p "$ZSH_PLUGINS_DIR"

# Function to clone and load plugin
load_plugin() {
  local repo=$1
  local plugin_name=$(basename "$repo" .git)
  local plugin_dir="$ZSH_PLUGINS_DIR/$plugin_name"
  
  # Clone if not exists
  if [[ ! -d "$plugin_dir" ]]; then
    git clone --depth=1 "https://github.com/$repo.git" "$plugin_dir" 2>/dev/null
  fi
  
  # Source the plugin
  if [[ -f "$plugin_dir/$plugin_name.plugin.zsh" ]]; then
    source "$plugin_dir/$plugin_name.plugin.zsh"
  elif [[ -f "$plugin_dir/$plugin_name.zsh" ]]; then
    source "$plugin_dir/$plugin_name.zsh"
  elif [[ -f "$plugin_dir/init.zsh" ]]; then
    source "$plugin_dir/init.zsh"
  elif [[ -f "$plugin_dir/$plugin_name.sh" ]]; then
    source "$plugin_dir/$plugin_name.sh"
  fi
}

# Load plugins in correct order
load_plugin "rupa/z"
load_plugin "zsh-users/zsh-autosuggestions"
load_plugin "zsh-users/zsh-syntax-highlighting"  # Always load last

# ============================================================================
# Pure Prompt Setup
# ============================================================================

# Install Pure prompt if not present
PURE_DIR="$HOME/.pure"
if [[ ! -d "$PURE_DIR" ]]; then
    git clone --depth=1 https://github.com/sindresorhus/pure.git "$PURE_DIR" 2>/dev/null
fi

# Add Pure to fpath and initialize
fpath+=("$PURE_DIR")
autoload -U promptinit; promptinit
prompt pure

# ============================================================================
# External Sources and Tools
# ============================================================================
# FZF
export FZF_DEFAULT_OPTS="
  --color=bg:#2E3440,bg+:#434C5E
  --color=spinner:#88C0D0,hl:#81A1C1
  --color=fg:#D8DEE9,header:#81A1C1
  --color=info:#EBCB8B,pointer:#88C0D0
  --color=marker:#A3BE8C,fg+:#ECEFF4
  --color=prompt:#8FBCBB,hl+:#5E81AC
  --layout=reverse
"
source <(fzf --zsh)
#
# Source custom scripts (if they exist)
[[ -f "$HOME/bin/uvenv" ]] && source "$HOME/bin/uvenv"

# Key remapping is handled by keyd system service
# No shell-level configuration needed

# Node version manager (fnm)
if [[ -d "$HOME/.local/share/fnm" ]]; then
  export PATH="$HOME/.local/share/fnm:$PATH"
  eval "$(fnm env)"
fi

# ============================================================================
# Aliases
# ============================================================================

# General utilities
alias o="xdg-open"
alias vim="nvim"
alias cat="batcat"
alias lg="lazygit"
alias untar="tar xvzf"
alias sjson="tr -d '\n'"
alias xclip="xclip -selection clipboard"

# Enable colors for ls
alias ls="ls --color=auto"
alias ll="ls -alF"
alias la="ls -A"
alias l="ls -CF"

# Configuration shortcuts
alias zshconfig="vim ~/.zshrc"
alias vimconfig="vim ~/.config/nvim/init.lua"
alias dotfiles="cd ~/dotfiles"

# Tmux shortcuts
alias tn="tmux new -s"
alias tl="tmux ls"
alias ta="tmux attach"

# Kubernetes shortcuts
alias k="kubectl"
alias kd="kubectl describe"
alias kg="kubectl get"
alias kgy="kubectl get -o yaml"

# Docker shortcuts
alias dps="docker ps --format 'table {{ .ID }}\t{{.Names}}\t{{.Status}}'"

# Development tools
alias helm="helm --debug"
alias ytd="youtube-dl --verbose -f best -o '%(title)s.%(ext)s'"

# Git aliases
alias gc="git commit -v -s"
alias gst="git status --short"
alias ga="git add"
alias gd="git diff --minimal"
alias gl="git log --oneline --decorate --graph"
alias gdc="git diff --cached"
alias gcan="git commit --amend --no-edit"

# ============================================================================
# Key Bindings and Vi Mode
# ============================================================================

# Enable vi mode
bindkey -v
export KEYTIMEOUT=1

# Yank to system clipboard in vi mode
function vi-yank-xclip {
    zle vi-yank
    echo "$CUTBUFFER" | xclip -selection clipboard
}
zle -N vi-yank-xclip
bindkey -M vicmd 'y' vi-yank-xclip

# Edit command line in editor
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd " " edit-command-line

# ============================================================================
# Prompt
# ============================================================================

# Pure prompt configuration (loaded via plugin system)
# Pure is async and will be available after plugin loading

eval "$(direnv hook zsh)"
