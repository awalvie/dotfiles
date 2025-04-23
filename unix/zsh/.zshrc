# exports
export EDITOR='nvim'
export ZSH="$HOME/.oh-my-zsh"
export GOPATH=$HOME/go

export PATH=$PATH:/usr/local/go/bin
export PATH=$HOME/bin:$PATH
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$HOME/.local/share/bob/nvim-bin
export PATH="$PATH/.local/bin:$PATH"
export BAT_THEME="Nord"

# Prune duplicates in $PATH
export PATH=$(echo -n $PATH | awk -v RS=: -v ORS=: '!($0 in a) {a[$0]; print}')

# GPG TTY
GPG_TTY=$(tty)
export GPG_TTY

# FZF colors: Generated from https://minsw.github.io/fzf-color-picker/
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
    --color=fg:#e5e9f0,bg:#2E3440,hl:#81a1c1
    --color=fg+:#e5e9f0,bg+:#2E3440,hl+:#81a1c1
    --color=info:#eacb8a,prompt:#bf6069,pointer:#b48dac
    --color=marker:#a3be8b,spinner:#b48dac,header:#a3be8b
	--height 60%
	--border sharp
	--layout reverse
	--prompt "∷ "
	--pointer ▶
	--marker ⇒'

# Enable colors and change prompt:
# sindresorhus/pure: https://github.com/sindresorhus/pure
fpath+=$HOME/.zsh/pure
autoload -U promptinit; promptinit
prompt pure


plugins=(
	z
	tmux
    fzf-tab
	direnv
	zsh-autosuggestions
	zsh-syntax-highlighting
)

# source shit
source $ZSH/oh-my-zsh.sh

# Use Xmodmap and xcape to
# Tap caps to act as esc
# Hold with hjkl to act as arrow keys
xmodmap ~/.Xmodmap
xcape -e 'Mode_switch=Escape'

# general aliases
alias o="xdg-open"
alias k="kubectl"
alias kd="kubectl describe"
alias kg="kubectl get"
alias kgy="kubectl get -o yaml"
alias vim="nvim"
alias tn="tmux new -s"
alias tl="tmux ls"
alias ta="tmux attach"
alias zshconfig="vim ~/.zshrc"
alias vimconfig="vim ~/.config/nvim/init.lua"
alias dotfiles="cd ~/dotfiles"
alias ytd="youtube-dl --verbose -f best -o '%(title)s.%(ext)s'"
alias dps="docker ps --format 'table {{ .ID }}\t{{.Names}}\t{{.Status}}'"
alias helm="helm --debug"
alias untar="tar xvzf"
alias sjson="tr -d '\n'"
alias xclip="xclip -selection clipboard"
alias lg="lazygit"
alias cat="bat"

# git aliases
alias gc="git commit -v -s"
alias gst="git status --short"
alias ga="git add"
alias gd="git diff --minimal"
alias gl="git log --oneline --decorate --graph"
alias gdc="git diff --cached"
alias gcan="git commit --amend --no-edit"

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Yank to the system clipboard
function vi-yank-xclip {
    zle vi-yank
   echo "$CUTBUFFER" | xclip -selection clipboard
}

zle -N vi-yank-xclip
bindkey -M vicmd 'y' vi-yank-xclip

# open in editor
autoload edit-command-line
zle -N edit-command-line
bindkey -M vicmd " " edit-command-line

# ctrl+r search history
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source /usr/share/doc/fzf/examples/key-bindings.zsh
source /usr/share/doc/fzf/examples/completion.zsh

# pyenv garbage
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# fnm
export PATH="$HOME/.local/share/fnm:$PATH"
eval "`fnm env`"

# fnm
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$HOME/.local/share/fnm:$PATH"
  eval "`fnm env`"
fi
