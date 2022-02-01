# exports
export EDITOR='nvim'
export ZSH="/home/awalvie/.oh-my-zsh"
export GOPATH=$HOME/go

export PATH=$PATH:/usr/local/go/bin
export PATH=$HOME/bin:$PATH
export PATH=$PATH:$GOPATH/bin/

plugins=(
	tmux
	zsh-autosuggestions
	zsh-syntax-highlighting
)

# source shit
source $ZSH/oh-my-zsh.sh

# Enable colors and change prompt:
# sindresorhus/pure: https://github.com/sindresorhus/pure
fpath+=$HOME/.zsh/pure
autoload -U promptinit; promptinit
prompt pure

# rupa/z
. ~/.z.sh

# general aliases
alias vim="nvim"
alias tn="tmux new -s"
alias tl="tmux ls"
alias ta="tmux attach"
alias zshconfig="vim ~/.zshrc"
alias vimconfig="vim ~/.config/nvim/init.vim"
alias dot="cd ~/dotfiles"
alias xclip="xclip -sel clip"

# git aliases
alias gc="git commit -v"
alias gst="git status --short"
alias ga="git add"
alias gd="git diff --minimal"
alias gl="git log --oneline --decorate --graph"
alias gdc="git diff --cached"

# vi mode
bindkey -v
export KEYTIMEOUT=1

# ctrl+r search history
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
