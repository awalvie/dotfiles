# ohmyzsh defaults
export ZSH="~/.oh-my-zsh"

# Theme
ZSH_THEME="robbyrussell"

plugins=(
	git
	tmux
	vi-mode
	zsh-autosuggestions
	zsh-syntax-highlighting
)


source $ZSH/oh-my-zsh.sh

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='nvim'
 else
   export EDITOR='vim'
 fi

# enable vim mode in terminal
bindkey -v

# alias's
alias zshconfig="mate ~/.zshrc"
alias ohmyzsh="mate ~/.oh-my-zsh"
alias open="xdg-open"
