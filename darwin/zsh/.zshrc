# exports
export PATH="/Users/garage/.local/bin:$PATH"
export PATH=$HOME/bin:$PATH
export PATH=$PATH:$GOPATH/bin/
export PATH="$PATH:$HOME/dotfiles/home/bin/"


export ZSH="/Users/garage/.oh-my-zsh"
export GOPATH=$HOME/go
export GPG_TTY=$(tty)

# fzf colors with alacritty nord
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
    --color=fg:#e5e9f0,bg:#2E3440,hl:#81a1c1
    --color=fg+:#e5e9f0,bg+:#2E3440,hl+:#81a1c1
    --color=info:#eacb8a,prompt:#bf6069,pointer:#b48dac
    --color=marker:#a3be8b,spinner:#b48dac,header:#a3be8b'

# Enable colors and change prompt:
# sindresorhus/pure: https://github.com/sindresorhus/pure
fpath+=$HOME/.zsh/pure
autoload -U promptinit; promptinit
prompt pure

plugins=(
	z
	tmux
	zsh-autosuggestions
	zsh-syntax-highlighting
	docker
	docker-compose
)


source $ZSH/oh-my-zsh.sh

export EDITOR='nvim'

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
alias code="open -b com.microsoft.VSCode"

# git aliases
alias gc="git commit -v"
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
   echo "$CUTBUFFER" | pbcopy -i
}

zle -N vi-yank-xclip
bindkey -M vicmd 'y' vi-yank-xclip

# open in editor
autoload edit-command-line
zle -N edit-command-line
bindkey -M vicmd " " edit-command-line

# ctrl+r search history
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# fnm config
eval "$(fnm env --use-on-cd)"
